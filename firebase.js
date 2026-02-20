import { initializeApp } from "https://www.gstatic.com/firebasejs/12.9.0/firebase-app.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/12.9.0/firebase-analytics.js";

const firebaseConfig = {
  apiKey: "AIzaSyAd6UM8y6m1hDVFWhlwjqj2UsZTIaggF1Y",
  authDomain: "boardpocket.firebaseapp.com",
  projectId: "boardpocket",
  storageBucket: "boardpocket.firebasestorage.app",
  messagingSenderId: "484852282867",
  appId: "1:484852282867:web:94d548dbd7db6992c20e86",
  measurementId: "G-MQ4870BEEZ"
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
