# Skill Tracker App Requirements Document

## 1. App Overview
This is an app to help people learn and practice new skills every day. It's for anyone who wants to build good habits, learn something new, or keep track of their progress in different activities. Think of it like a personal coach in your phone that helps you stay motivated and see how far you've come.

## 2. Main Goals
1. Help users set and track daily and weekly skills
2. Make it easy to check off completed tasks
3. Show progress over time
4. Keep users motivated to learn and practice

## 3. User Stories
- US-001: As a user, I want to add my own skills so that I can tra ck things important to me
- US-002: As a user, I want to check off tasks when I complete them so that I can see my daily progress
- US-003: As a user, I want to see my progress over time so that I can feel motivated
- US-004: As a user, I want to set different frequencies for tasks (daily, twice a week) so that I can match my learning schedule

## 4. Features
- F-001: Add new skills to track
  - What it does: Let users type in a new skill
  - When it appears: On a "Add Skill" screen
  - If something goes wrong: Show a clear error message if skill can't be added

- F-002: Mark tasks as complete
  - What it does: Let users tap a checkbox to mark a task done
  - When it appears: On the home screen with daily tasks
  - If something goes wrong: Keep the task unchecked if it can't be marked complete

- F-003: Track skill frequency
  - What it does: Allow setting tasks for specific frequencies (daily, weekly)
  - When it appears: When adding or editing a skill
  - If something goes wrong: Default to daily if frequency can't be set

- F-004: Progress tracking
  - What it does: Show charts or lists of completed and missed tasks
  - When it appears: On a separate "Progress" screen
  - If something goes wrong: Show a message that no progress data is available

## 5. Screens
- S-001: Home Screen
  - What's on the screen: List of today's tasks that can be checked off
  - How to get there: First screen when opening the app

- S-002: Add Skill Screen
  - What's on the screen: Form to add a new skill, set frequency, and details
  - How to get there: Tap a "+" button on the home screen

- S-003: Progress Screen
  - What's on the screen: Charts or lists showing task completion over time
  - How to get there: Tap a "Progress" tab or button

## 6. Data
- D-001: List of skills with name, frequency, and tracking details
- D-002: Daily completion status for each skill
- D-003: Streak tracking (how many days in a row a task has been completed)
- D-004: Historical completion data for progress tracking

## 7. Extra Details
- Needs internet: No (works completely offline)
- Data storage: On the device using Core Data or similar local storage
- Permissions needed: None initially
- Dark mode: Yes, support both light and dark modes
- Backup option: Allow exporting progress data

## 8. Build Steps
- B-001: Create basic home screen (S-001)
  - Display "Today's Tasks" at the top
  - Implement static task list with categories
  - Add time-based greeting (Good morning/afternoon/evening)

- B-002: Develop Skill Management System
  - Create Slider functionality to:
    - Edit existing skills
    - Delete skills
    - Adjust skill parameters

- B-003: Implement Comprehensive Skill Input
  - Design skill creation screen with:
    - Skill name input
    - Category selection (dropdown/list)
    - Frequency options
    - Time frame setting (start/end dates)
    - Tracking metrics (daily/weekly goals)

- B-004: Category Management
  - Create predefined categories
  - Allow custom category creation
  - Group skills by categories on home screen
  - Color-code or icon-tag categories

- B-005: Progress Tracking Screen (Inspired by HelloHabit)
  - Create grid-based progress visualization
  - Show completion percentages
  - Display streak tracking
  - Provide annual/monthly/weekly views
  - Color-code completion states (completed/partial/missed)

- B-006: Time-Based Greeting Feature
  - Implement dynamic greeting that changes based on:
    - Current time of day
    - Optional personalization
  ## - Motivational messages

- B-007: Skill Time Frame Management
  - Allow setting specific duration for skills
  - Automatic skill archiving/deactivation
  - Reminder system for skill review

- B-008: Data Persistence
  - Save skill data
  - Track historical performance
  - Allow data export/import

- B-009: Advanced Tracking Features
  - Implement detailed analytics
  - Show improvement trends
  - Provide insights into skill progression

## New Feature Details

### Skill Input Screen Enhancements
- Category Selection Options:
  1. Personal Development
  2. Fitness
  3. Learning
  4. Professional Growth
  5. Health
  6. Creative Skills
  7. Mindfulness
  8. Custom Category

### Progress Tracking Screen Specifics
- Heatmap-style grid showing:
  - Daily/weekly completion
  - Color intensity representing performance
  - Percentage completion for each skill
  - Ability to tap into detailed skill history

### Time-Based Greeting Examples
- 5:00 AM - 11:59 AM: "Good Morning, [Optional Name]!"
- 12:00 PM - 5:59 PM: "Good Afternoon, ready to crush your goals?"
- 6:00 PM - 4:59 AM: "Good Evening, how are your skills progressing?"

### Skill Time Frame Options
- Fixed duration skills (e.g., 30-day challenge)
- Recurring skills (daily/weekly/monthly)
- Open-ended skills
- Automatic skill archiving
- Skill review reminders