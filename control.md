🛠️ How to Control the App
To turn the app ON or OFF, follow these steps in your Firebase Console:

Go to Firestore Database.
Create a new Collection named ( app_config ).
Create a Document ID named ( status ) inside that collection.
Add the following fields:
Field: ( isActive ) | Type: ( boolean ) | Value: ( true ) App works or ( false ) App locks.
Field: ( message ) | Type: ( string ) | Value: (Optional) Use this to set a custom professional message.