const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase LBTA!");
});

exports.sendFollowerNotification = functions.database.ref('/userChatNoti/{uid}/{chatKey}')
    .onWrite(async (change, context) => {
      const gettingUID = context.params.uid;
      const chatKey = context.params.chatKey;
      // If un-follow we exit the function.
      if (!change.after.val()) {
        return console.log('User ', gettingUID, 'is receiving a message in group', chatKey);
      }

      // Get the list of device notification tokens.
      const getDeviceTokensPromise = admin.database()
          .ref(`/fcmToken/${gettingUID}`).once('value');

      // get Game_Chat_Info

      const getInfoProfile = admin.database().ref(`/Order_Chat_Info/${chatKey}`).once('value');

          // The snapshot to the user's tokens.
          let tokensSnapshot;

          // The array containing all the user's tokens.
          let tokens;

          const results = await Promise.all([getDeviceTokensPromise, getInfoProfile]);
          tokensSnapshot = results[0];
          const infomation = results[1];


          // Check if there are any device tokens.
       if (!tokensSnapshot.hasChildren()) {
         return console.log('There are no notification tokens to send to.');
       }

       console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
       console.log('Order id', infomation.val().order_id);

       // Notification details.
       var payload = {
         notification: {
           title: `Order #CC - ${infomation.val().order_id}`,
           body: `${infomation.val().Last_message}`,
           badge : '1',
           sound: 'default',
         },
         data: {
           followerId: chatKey
         }
       }

       // Listing all tokens as an array.
       tokens = Object.keys(tokensSnapshot.val());
       // Send notifications to all tokens.
       console.log(tokens[0]);
       const response = await admin.messaging().sendToDevice(tokens, payload);
       // For each message check if there was an error.
       const tokensToRemove = [];
       response.results.forEach((result, index) => {
         const error = result.error;
         if (error) {
           console.error('Failure sending notification to', tokens[index], error);
           // Cleanup the tokens who are not registered anymore.
           if (error.code === 'messaging/invalid-registration-token' ||
               error.code === 'messaging/registration-token-not-registered') {
             tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
           }
         } else {
           console.log('sent Successfully');
         }
       });
       return Promise.all(tokensToRemove);


});


exports.userReadyNoti = functions.database.ref('/userReadyNoti/{uid}/{orderKey}')
    .onWrite(async (change, context) => {
      const gettingUID = context.params.uid;
      const orderKey = context.params.orderKey;
      // If un-follow we exit the function.
      if (!change.after.val()) {
        return console.log('User ', gettingUID, 'is receiving a ready notification for order', orderKey);
      }

      // Get the list of device notification tokens.
      const getDeviceTokensPromise = admin.database()
          .ref(`/fcmToken/${gettingUID}`).once('value');

          // The snapshot to the user's tokens.
          let tokensSnapshot;

          // The array containing all the user's tokens.
          let tokens;

          const results = await Promise.all([getDeviceTokensPromise]);
          tokensSnapshot = results[0];



          // Check if there are any device tokens.
       if (!tokensSnapshot.hasChildren()) {
         return console.log('There are no notification tokens to send to.');
       }

       console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
       console.log('Order id', orderKey);

       // Notification details.
       var payload = {
         notification: {
           title: `Order #CC - ${orderKey}`,
           body: `Your order is ready for pick up`,
           badge : '1',
           sound: 'default',
         },
         data: {
           followerId: orderKey
         }
       }

       // Listing all tokens as an array.
       tokens = Object.keys(tokensSnapshot.val());
       // Send notifications to all tokens.
       console.log(tokens[0]);
       const response = await admin.messaging().sendToDevice(tokens, payload);
       // For each message check if there was an error.
       const tokensToRemove = [];
       response.results.forEach((result, index) => {
         const error = result.error;
         if (error) {
           console.error('Failure sending notification to', tokens[index], error);
           // Cleanup the tokens who are not registered anymore.
           if (error.code === 'messaging/invalid-registration-token' ||
               error.code === 'messaging/registration-token-not-registered') {
             tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
           }
         } else {
           console.log('sent Successfully');
         }
       });
       return Promise.all(tokensToRemove);


});


exports.userStartNoti = functions.database.ref('/userStartNoti/{uid}/{orderKey}')
    .onWrite(async (change, context) => {
      const gettingUID = context.params.uid;
      const orderKey = context.params.orderKey;
      // If un-follow we exit the function.
      if (!change.after.val()) {
        return console.log('User ', gettingUID, 'is receiving a picking up notification for order', orderKey);
      }

      // Get the list of device notification tokens.
      const getDeviceTokensPromise = admin.database()
          .ref(`/fcmToken/${gettingUID}`).once('value');

          // The snapshot to the user's tokens.
          let tokensSnapshot;

          // The array containing all the user's tokens.
          let tokens;

          const results = await Promise.all([getDeviceTokensPromise]);
          tokensSnapshot = results[0];



          // Check if there are any device tokens.
       if (!tokensSnapshot.hasChildren()) {
         return console.log('There are no notification tokens to send to.');
       }

       console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
       console.log('Order id', orderKey);

       // Notification details.
       var payload = {
         notification: {
           title: `Order #CC - ${orderKey}`,
           body: `Your order has been started cooking`,
           badge : '1',
           sound: 'default',
         },
         data: {
           followerId: orderKey
         }
       }

       // Listing all tokens as an array.
       tokens = Object.keys(tokensSnapshot.val());
       // Send notifications to all tokens.
       console.log(tokens[0]);
       const response = await admin.messaging().sendToDevice(tokens, payload);
       // For each message check if there was an error.
       const tokensToRemove = [];
       response.results.forEach((result, index) => {
         const error = result.error;
         if (error) {
           console.error('Failure sending notification to', tokens[index], error);
           // Cleanup the tokens who are not registered anymore.
           if (error.code === 'messaging/invalid-registration-token' ||
               error.code === 'messaging/registration-token-not-registered') {
             tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
           }
         } else {
           console.log('sent Successfully');
         }
       });
       return Promise.all(tokensToRemove);


});


exports.restaurantNoti = functions.database.ref('/restaurantNoti/{uid}/{orderKey}')
    .onWrite(async (change, context) => {
      const gettingUID = context.params.uid;
      const orderKey = context.params.orderKey;
      // If un-follow we exit the function.
      if (!change.after.val()) {
        return console.log('User ', gettingUID, 'is receiving a notification for new order', orderKey);
      }

      // Get the list of device notification tokens.
      const getDeviceTokensPromise = admin.database()
          .ref(`/fcmToken/${gettingUID}`).once('value');

          // The snapshot to the user's tokens.
          let tokensSnapshot;

          // The array containing all the user's tokens.
          let tokens;

          const results = await Promise.all([getDeviceTokensPromise]);
          tokensSnapshot = results[0];



          // Check if there are any device tokens.
       if (!tokensSnapshot.hasChildren()) {
         return console.log('There are no notification tokens to send to.');
       }

       console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
       console.log('Order id', orderKey);

       // Notification details.
       var payload = {
         notification: {
           title: `Order #CC - ${orderKey}`,
           body: `You just have a new order #CC - ${orderKey} `,
           badge : '1',
           sound: 'default',
         },
         data: {
           followerId: orderKey
         }
       }

       // Listing all tokens as an array.
       tokens = Object.keys(tokensSnapshot.val());
       // Send notifications to all tokens.
       console.log(tokens[0]);
       const response = await admin.messaging().sendToDevice(tokens, payload);
       // For each message check if there was an error.
       const tokensToRemove = [];
       response.results.forEach((result, index) => {
         const error = result.error;
         if (error) {
           console.error('Failure sending notification to', tokens[index], error);
           // Cleanup the tokens who are not registered anymore.
           if (error.code === 'messaging/invalid-registration-token' ||
               error.code === 'messaging/registration-token-not-registered') {
             tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
           }
         } else {
           console.log('sent Successfully');
         }
       });
       return Promise.all(tokensToRemove);


});
