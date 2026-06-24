# Political Movement Tracker & Admin Panel

This project contains a landing page and administration panel for tracking target participation in the movement.

## Features

- **Landing Page (`index.html`)**: Features sign-up form with input validation and integration with Supabase for data recording.
- **Admin Dashboard (`admin.html`)**: Real-time stats dashboard, targets management, live monitoring, activity logs, MITM controls, and mobile device tracking simulation.

## Setup & Tech Stack

- **Frontend**: Plain HTML5, CSS3, JavaScript.
- **Backend Integration**: Supabase JavaScript SDK.
- **Real-Time updates**: Supabase Postgres Changes subscription.

## Database Setup (Supabase)

To run this application, you must set up the required tables and security policies in your Supabase project:
1. Open your Supabase Dashboard and go to the **SQL Editor**.
2. Create a new query.
3. Copy the entire contents of [schema.sql](file:///C:/Users/xingk/tracker/schema.sql).
4. Paste it into the editor and click **Run**.
5. Ensure your API keys in `index.html` and `admin.html` match your project's credentials.

