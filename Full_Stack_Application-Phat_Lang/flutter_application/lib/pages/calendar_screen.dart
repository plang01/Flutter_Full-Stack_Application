import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // clientID is stored in .env file
    clientId: dotenv.env['GOOGLE_CLIENT_ID'],
    scopes: [
      calendar.CalendarApi.calendarScope,
    ],
  );

  GoogleSignInAccount? _currentUser;

  late calendar.CalendarApi calendarAPI;
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      // make sure the widget is not disposed before calling setState, without it there will be error
      if (mounted) {
        setState(() {
          _currentUser = account;
        });
      }
    });
    // One Tap Sign In UI
    _googleSignIn.signInSilently();
  }

  Future<void> getCalendarData() async {
    await googleSignIn();
    /* Show List of Calendar ID & Summary (Calendar Name) */
    // final calendarList = await calendarAPI.calendarList.list();
    // if(calendarList.items!.isNotEmpty) {
    //   print('Starting Calendar List Loop:');
    //   for(int i = 0; i < calendarList.items!.length; i ++) {
    //     print('ID: ${calendarList.items?[i].id}, Summary: ${calendarList.items?[i].summary}');
    //   }
    // }

    /* Get all events Summary(Title) of the Primary Calendar
    null events have cancelled status
    parameter singleEvents break down the recurring event into individual instance
    parameter timeMin (inclusive), timeMax (exclusive). Set lower & upper bound query
    */
    DateTime startTime = DateTime(2024,7, 1);
    DateTime endTime = DateTime(2024, 8, 1);
    final eventList = await calendarAPI.events.list('primary', maxResults: 2000, timeMin: startTime, timeMax: endTime,showHiddenInvitations: false, showDeleted: false, singleEvents: true);
    if (eventList.items!.isNotEmpty) {
      print('Starting Event List Loop:');
      for(int i = 0; i < eventList.items!.length; i++) {
        calendar.EventDateTime? start = eventList.items?[i].start;
        print('Title: ${eventList.items?[i].summary}, Start Time: ${start?.dateTime?.year}-${start?.dateTime?.month}-${start?.dateTime?.day}, ID: ${eventList.items?[i].id}');
      }
    }
  }

  /* Creating a single new event */
  Future<void> createSingleCalendarEvent() async {
    await googleSignIn();
    DateTime insertStartTime = DateTime(2024, 7, 20, 9);
    DateTime insertEndTime = DateTime(2024, 7, 20, 12);
    String location = 'https://uml.zoom.us/j/98269214484';
    String description = 'https://uml.zoom.us/j/98269214484';
    calendar.EventDateTime eventStartTime = calendar.EventDateTime(dateTime: insertStartTime, timeZone: 'America/New_York');
    calendar.EventDateTime eventEndTime = calendar.EventDateTime(dateTime: insertEndTime, timeZone: 'America/New_York');
    // Start & end time parameters use EventDateTime object
    calendar.Event eventJson = calendar.Event(start: eventStartTime, end: eventEndTime, summary: 'POC_Single_Event', description: description);
    try {
      await calendarAPI.events.insert(eventJson, 'primary');
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        }
      );
    } catch (e) {
      print(e);
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Failure'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        }
      );
    }
  }

  /* Create a recurring event & invite a guest */
  Future<void> createRecurringCalendarEvent () async {
    await googleSignIn();
    DateTime insertStartTime = DateTime(2024, 7, 14, 9);
    DateTime insertEndTime = DateTime(2024, 7, 14, 12);
    String location = 'https://uml.zoom.us/j/98269214484';
    String description = 'https://uml.zoom.us/j/98269214484';
    calendar.EventAttendee attendee = calendar.EventAttendee(email: 'testpythonscript224@gmail.com');
    calendar.EventDateTime eventStartTime = calendar.EventDateTime(dateTime: insertStartTime, timeZone: 'America/New_York');
    calendar.EventDateTime eventEndTime = calendar.EventDateTime(dateTime: insertEndTime, timeZone: 'America/New_York');
    calendar.Event eventJson = calendar.Event(start: eventStartTime, end: eventEndTime, attendees: [attendee],recurrence: ["RRULE:FREQ=WEEKLY;UNTIL=20241001T170000Z;BYDAY=SU,MO,TU"],summary: 'POC_Recurring_Event', description: description);
    try {
      await calendarAPI.events.insert(eventJson, 'primary');
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        }
      );
    } catch (e) {
      print(e);
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Failed'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        }
      );
    }
  }

  Future<void> updateCalendarEvent() async {
    await googleSignIn();
    DateTime newStartTime = DateTime(2024, 7, 15, 9);
    DateTime newEndTime = DateTime(2024, 7, 15, 12);
    calendar.EventDateTime eventStartTime = calendar.EventDateTime(dateTime: newStartTime, timeZone: 'America/New_York');
    calendar.EventDateTime eventEndTime = calendar.EventDateTime(dateTime: newEndTime, timeZone: 'America/New_York');
    try {
      calendar.Event result = await calendarAPI.events.get('primary', '2u7ve6c4fopl0172jkg31tcs3e');
      String? eventID = result.id;
      if(eventID!= null) {
        result.start = eventStartTime;
        result.end = eventEndTime;
        await calendarAPI.events.update(result, 'primary', eventID);
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Update Successfully'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              );
            }
        );
      }
      else {
        throw Exception('Unable to find the event ID');
      }
    } catch (e) {
      print(e);
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Failed to Update'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            );
          }
      );
    }
  }

  Future<void> googleSignIn() async {
    try {
      GoogleSignInAccount? result =  await _googleSignIn.signIn();
      // Check & request access authorization for Google Calendar API
      final bool isAuthorized = await _googleSignIn.canAccessScopes([calendar.CalendarApi.calendarScope]);
      if (isAuthorized == false) {
        await _googleSignIn.requestScopes([calendar.CalendarApi.calendarScope]);
      }
      if (result != null) {
        final authClient = await _googleSignIn.authenticatedClient();
        if (authClient != null) {
          calendarAPI = calendar.CalendarApi(authClient);
        }
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> googleSignOut() async {
    await _googleSignIn.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Calendar Integration'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          _buildBody(),
        ]
      ),
    );
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ElevatedButton(
            onPressed: googleSignOut,
            child: const Text('Sign out'),
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: getCalendarData,
                child: const Text('Show Entries'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: updateCalendarEvent,
                child: Text('Update an Event'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: createSingleCalendarEvent,
                child: const Text('Add Single Event'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                  onPressed: createRecurringCalendarEvent,
                  child: Text('Add Recurring Event'),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          ElevatedButton(
            child: const Text('Sign In'),
            onPressed: googleSignIn,
          ),
          renderButton(),
        ]
      );
    }
  }
}
