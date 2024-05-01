import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import html
import base64
import re
import argparse
from pymongo import MongoClient
import schedule
import time
# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/gmail.readonly", "https://www.googleapis.com/auth/gmail.modify"]


fetch_label = 'label: INBOX label:UNREAD'
success_label = 'Success'
failure_label = 'Failure'
mark_read_label = ""
success_label_ID = None
failure_label_ID = None
data_list = []
# Regex expression for capturing key words and client's name
regex_subject_key_words = r"\bnew user(s)?\b"
regex_name_signature = r"(\s)*(Best Regard(s)?|Sincerely|Thank you|Thank(s)?),( )*(\r\n|\r|\n)+([a-zA-Z][a-zA-Z @\d]*)"


def fetch_new_user_name():
  """Shows basic usage of the Gmail API.
  Lists the user's Gmail labels.
  """
  creds = None
  # The file token.json stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
  # If there are no (valid) credentials available, let the user log in.
  if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
      creds.refresh(Request())
    else:
      flow = InstalledAppFlow.from_client_secrets_file(
          "test_account_credentials.json", SCOPES
      )
      creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open("token.json", "w") as token:
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
                          '''In the work'''
                          # return_list_name = retrieveData(email_from)
                          # if(len(return_list_name) == 0):
                          #   client_info = {'name': capture_name, 'email': email_from}
                          #   data_list.append(client_info);   
                          # else:
                          #   different_name = True
                          #   for name in return_list_name:
                          #     if(name == capture_name):
                          #       different_name = False
                          #       break
                          #   if(different_name):
                              
                            
                          ''' Original '''
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


def postData(data):
  client = MongoClient("localhost", 27017)

  db_collection = client.clients_list

  client_db = db_collection.clients_name

  result = client_db.insert_many(data)
  print(result.inserted_ids)


def retrieveData(email):
  client = MongoClient('localhost', 27017)

  db_collection = client.clients_list

  client_db = db_collection.clients_name

  list_name = []
  names = client_db.find({'email': email})
  for name in names:
    list_name.append(name)
  return list_name


def getName(test_body):
  # This regex assumes the client's name is precedes by commonly used email-signoff
  regex_name_signature = r"(\s)*(Best Regard(s)?|Sincerely|Thank you|Thank(s)*),( )*(\r\n|\r|\n)+([a-zA-Z][a-zA-z @\d]*)"
  name = None
  match = re.search(regex_name_signature, test_body)
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


def automate_script():
  # schedule.every(1).minutes.do(fetch_new_user_name)
  schedule.every(15).seconds.do(fetch_new_user_name)
  while True:
    schedule.run_pending()
    time.sleep(1)


def readFile():
  parser = argparse.ArgumentParser()
  parser.add_argument('file', type=str)
  parser.add_argument('file2', type=str)
  args = parser.parse_args()
  email_body1 = None
  try:
    with open(args.file, 'r') as file:
        email_body1 = file.read()
  except FileNotFoundError:
    print("File not found")

  try:
    with open(args.file2, 'r') as file:
      email_body2 = file.read()
      # print(email_body2)

  except FileNotFoundError:
    print("Cannot Open File 2")

  if(email_body1 == email_body2):
    print("Matched")
  else:
    print("Not Matched")

  getName(email_body1)


if __name__ == "__main__":
  # retrieveData('plang1286@gmail.com')
  automate_script()
  # fetch_new_user_name()
  # readFile()