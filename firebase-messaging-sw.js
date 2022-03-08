importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

//MANABE: Place your config from firebase (app should be created as web/html)
firebase.initializeApp({
    apiKey: "AIzaSyBgIiRep7VsTD8A45bQf6gkzxbMt7NnSL4",
    authDomain: "omega-metric-229914.firebaseapp.com",
    projectId: "omega-metric-229914",
    storageBucket: "omega-metric-229914.appspot.com",
    messagingSenderId: "1063833877818",
    appId: "1:1063833877818:web:ee6fac33a8239be0d02403",
    measurementId: "G-494G8RB67K"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

//Flutter cannot handle background notifications in web yet
messaging.onBackgroundMessage((m) => {
    console.log("js worker: onBackgroundMessage", m);
});
