import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import base64
import re
from pymongo import MongoClient
import schedule
import time
# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/gmail.readonly", "https://www.googleapis.com/auth/gmail.modify"]


# Credential file is the one downloaded from OAuth2.0 
credential_json_file = "test_account_credentials.json"
# The file token_json_file_name stores the user's access and refresh tokens, automatically created
# when authorize for the first time
token_json_file_name = "token.json"

fetch_label = 'label: INBOX label:UNREAD'
success_label = 'Success'
failure_label = 'Failure'
success_label_ID = None
failure_label_ID = None
data_list = []
# Specified MongoDB database & collection names
database_name = "clients_list"
collection_name = "clients_name"
# Regex expression for capturing key words and client's name
regex_subject_key_words = r"\bnew user(s)?\b"
regex_name_signature = r"(\s)*(Best Regard(s)?|Sincerely|Thank you|Thank(s)?),( )*(\r\n|\r|\n)+([a-zA-Z][a-zA-Z @\d]*)"


'''
Functionality:
  Connect to Gmail API, fetch new email in the INBOX that contains specified key words in SUBJECT header
  Scan the contents, if it's able to caputre the name from email signature, mark it as UNREAD and add SUCCESS label tag
  If not able to capture the name, move the email out of INBOX and add Failure label
  Post the name to a local database
'''
def fetch_new_user_name():
  creds = None
  # The file token_json_file_name stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  if os.path.exists(token_json_file_name):
    creds = Credentials.from_authorized_user_file(token_json_file_name, SCOPES)
  # If there are no (valid) credentials available, let the user log in.
  if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
      creds.refresh(Request())
    else:
      flow = InstalledAppFlow.from_client_secrets_file(
          credential_json_file, SCOPES
      )
      creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open(token_json_file_name, "w") as token:
      token.write(creds.to_json())

  try:
    # Call the Gmail API
    service = build("gmail", "v1", credentials=creds)
    results = service.users().labels().list(userId="me").execute()
    labels = results.get("labels", [])

    # List out all the labels
    if not labels:
      print("No labels found.")
      return
    # Get label id from the name
    for label in labels:
      if(label['name'] == success_label):
        success_label_ID = label['id']
      elif(label['name'] == failure_label):
        failure_label_ID = label['id']

    # To fetch label, passing the q parameter to query specific label 
    fetch_result = service.users().messages().list(userId='me', q=fetch_label).execute()
    messages = fetch_result.get('messages', [])

    if not messages:
      print('No messages found.')
    else:
      for message in messages:
            msg = service.users().messages().get(userId='me', id=message['id']).execute()
            for header in msg['payload']['headers']:
                # Grab the client's email address
                if(header['name'] == 'From'):
                  header_from = header['value']
                  capture_email = re.search(r"(<)(.*)(>)", header_from)
                  if capture_email:
                    email_from = capture_email.group(2)
                  else:
                    print("Cannot capture email address")

                # Grab the subject header
                if (header['name'] == 'Subject'):
                    # Select emails with subject line containing specific keyword and ignore case
                    is_new_user = re.search( regex_subject_key_words, header['value'], re.IGNORECASE)
                    if(is_new_user):
                        # Fetch content emails and decode it to string
                        email_data = msg['payload']['parts'][0]['body']['data']
                        decoded_data_bytes = base64.urlsafe_b64decode(email_data.encode('UTF-8'))
                        email_content = decoded_data_bytes.decode('UTF-8').strip()
                
                        # Call function getName to capture client's name
                        capture_name = getName(email_content)
                        if capture_name:                            
                          client_info = {'name': capture_name, 'email': email_from}
                          data_list.append(client_info); 
                          # Marked email as unread and Success label to it 
                          service.users().messages().modify(userId='me', id=message['id'], body={'addLabelIds': [success_label_ID], 'removeLabelIds':['UNREAD']}).execute()
                        else:
                          # Move it out from Inbox and add Failure label since we can't fetch user's name from email and need to manually review
                          service.users().messages().modify(userId='me', id=message['id'], body={'addLabelIds': [failure_label_ID], 'removeLabelIds': ['INBOX']}).execute()           
      
      # If there's data in the list, post it to database
      if len(data_list) != 0:
        postData(data_list)
        # Clear the data list
        data_list.clear()

  except HttpError as error:
    # TODO(developer) - Handle errors from gmail API.
    print(f"An error occurred: {error}")


'''
Argument:
  data: dictionary of data

Functionality:
  Access the MongoDB databse and insert the data. Then output the id 
'''
def postData(data):
  client = MongoClient("localhost", 27017)

  db_collection = client[database_name]

  client_db = db_collection[collection_name]

  result = client_db.insert_many(data)
  print(result.inserted_ids)


'''
Argument:
  email: email address

Functionality: 
  Search the database with given email and return dictionary of name, not use at the current moment
'''
def retrieveData(email):
  client = MongoClient('localhost', 27017)

  db_collection = client[database_name]

  client_db = db_collection[collection_name]

  list_name = []
  names = client_db.find({'email': email})
  for name in names:
    list_name.append(name)
  return list_name


'''
Argument:
  text_body: the content of email body

Functionality:
  Use a regex to capure the name and return it, if not successful it returns None
'''
def getName(text_body):
  # This regex assumes the client's name is precedes by commonly used email-signoff
  # regex_name_signature = r"(\s)*(Best Regard(s)?|Sincerely|Thank you|Thank(s)*),( )*(\r\n|\r|\n)+([a-zA-Z][a-zA-z @\d]*)"
  name = None
  match = re.search(regex_name_signature, text_body)
  if match:
      '''
      Every open parentheses represent capture group number, since we want to capure the last part ([a-zA-Z][a-zA-z @\\d]*)
      Simply count number of parentheses until the desired caputure group
      '''
      potentialName = match.group(7)
      email = re.search('@', potentialName)
      if not email:
        name = potentialName
  return name


'''
Functionality:
  Use schedule module to periodically call function fetch_new_user_name at specified time interval
'''
def automate_script():
  schedule.every(30).seconds.do(fetch_new_user_name)
  while True:
    schedule.run_pending()
    time.sleep(1)


if __name__ == "__main__":
  automate_script()