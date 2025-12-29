# Skill Tracker App Requirements Document

## 1. App Overview
This is an app to help people learn and practice new skills every day. It's for anyone who wants to build good habits, learn something new, or keep track of their progress in different activities. Think of it like a personal coach in your phone that helps you stay motivated and see how far you've come.

## 2. Main Goals
1. Help users set and track daily and weekly skills
2. Make it easy to check off completed tasks
3. Show progress over time
4. Keep users motivated to learn and practice

## 3. User Stories
- US-001: As a user, I want to add my own skills so that I can track things important to me
- US-002: As a user, I want to check off tasks when I complete them so that I can see my daily progress
- US-003: As a user, I want to see my progress over time so that I can feel motivated
- US-004: As a user, I want to set different frequencies for tasks (daily, twice a week) so that I can match my learning schedule
- US-005: As a user, I want to track partial completion of tasks so that I can acknowledge partial progress
- US-006: As a user, I want to rollover incomplete tasks to the next day so that I don't lose track of important tasks
- US-007: As a user, I want to track my morning routine habits so that I can build consistent daily habits
- US-008: As a user, I want to view my progress in week, month, and year views so that I can see long-term trends
- US-009: As a user, I want to record memorable moments so that I can celebrate achievements and milestones

## 4. Features
- F-001: Add new skills to track
  - What it does: Let users type in a new skill
  - When it appears: On a "Add Skill" screen
  - If something goes wrong: Show a clear error message if skill can't be added

- F-002: Mark tasks as complete (with partial completion support)
  - What it does: Let users tap a checkbox to mark a task done, or mark as partially complete
  - When it appears: On the home screen with daily tasks
  - If something goes wrong: Keep the task unchecked if it can't be marked complete
  - Color coding: Light color for partial completion, dark color for full completion

- F-003: Track skill frequency
  - What it does: Allow setting tasks for specific frequencies (daily, weekly)
  - When it appears: When adding or editing a skill
  - If something goes wrong: Default to daily if frequency can't be set

- F-004: Git-style progress tracking
  - What it does: Show heatmap-style grid of completed and missed tasks with color intensity
  - When it appears: On a separate "Progress" screen
  - If something goes wrong: Show a message that no progress data is available
  - Color scheme: Light colors for partial completion, dark colors for full completion

- F-005: Interactive week calendar
  - What it does: Display a scrollable week calendar on the home screen
  - When it appears: On the home screen, above the tasks section
  - Features: Highlight current day, navigate between weeks, select dates to view tasks

- F-006: Morning routine tracking
  - What it does: Track specific morning habits (Read 10 pages, Stretch, Track weight, Drink 500ml water)
  - When it appears: On the home screen, below the calendar
  - Features: Partial and full completion tracking, visual progress indicators

- F-007: Task rollover
  - What it does: Allow incomplete tasks to be moved to the next day
  - When it appears: On task cards with rollover enabled
  - Features: Visual indicator for rolled over tasks, automatic processing

- F-008: Comprehensive tracking views
  - What it does: Display progress in week, month, and year views
  - When it appears: On the Progress screen
  - Features: Calendar grid layouts, completion percentages, color-coded indicators

- F-009: Memorable moments
  - What it does: Allow users to record and view special achievements and milestones
  - When it appears: Can be added from task completion or progress screens
  - Features: Categorization, date tracking, descriptions

## 5. Screens
- S-001: Home Screen
  - What's on the screen: 
    * Interactive week calendar (scrollable, highlights current day)
    * Morning routine section with 4 specific habits
    * List of tasks for selected date (supports partial completion and rollover)
    * Quick add button for new skills
  - How to get there: First screen when opening the app
  - Design: Clean, minimalist design with purple/blue color scheme

- S-002: Add Skill Screen
  - What's on the screen: Form to add a new skill, set frequency, and details
  - How to get there: Tap a "+" button on the home screen
  - Features: Simplified task input, rollover option, category selection

- S-003: Progress Screen
  - What's on the screen: 
    * Git-style heatmap grid showing completion history
    * Week, month, and year view options
    * Color-coded completion states (light = partial, dark = full)
    * Overall statistics and skill-specific progress
  - How to get there: Tap a "Progress" tab or button
  - Features: Export/import data, memorable moments integration

## 6. Data
- D-001: List of skills with name, frequency, and tracking details
- D-002: Daily completion status for each skill (with partial completion support)
- D-003: Historical completion data for progress tracking (removed streak tracking)
- D-004: Morning routine completion data (habit ID + date -> completion level)
- D-005: Rolled over tasks (skill ID -> rollover date)
- D-006: Memorable moments (achievements, milestones, personal notes)

## 7. Extra Details
- Needs internet: No (works completely offline)
- Data storage: On the device using Core Data or similar local storage
- Permissions needed: None initially
- Dark mode: Yes, support both light and dark modes
- Backup option: Allow exporting progress data

## 8. Build Steps
- B-001: Create basic home screen (S-001)
  - Display time-based greeting (Good morning/afternoon/evening)
  - Add interactive week calendar (see B-010)
  - Add morning routine section (see B-011)
  - Display tasks for selected date with partial completion support
  - Remove login and notifications buttons
  - Add quick task creation button

- B-002: Develop Skill Management System
  - Create functionality to:
    - Edit existing skills
    - Delete skills
    - Adjust skill parameters
    - Enable/disable task rollover

- B-003: Implement Comprehensive Skill Input
  - Design skill creation screen with:
    - Skill name input
    - Category selection (dropdown/list)
    - Frequency options
    - Time frame setting (start/end dates)
    - Tracking metrics (daily/weekly goals)
    - Rollover option toggle

- B-004: Category Management
  - Create predefined categories
  - Allow custom category creation
  - Group skills by categories on home screen
  - Color-code or icon-tag categories

- B-005: Git-Style Progress Tracking Screen
  - Create heatmap grid-based progress visualization
  - Show completion percentages
  - Provide annual/monthly/weekly views (see B-012)
  - Color-code completion states:
    * Light color: Partial completion
    * Dark color: Full completion
    * Gray: No completion
  - Remove streak tracking mechanism

- B-006: Time-Based Greeting Feature
  - Implement dynamic greeting that changes based on:
    - Current time of day
    - Optional personalization
  - Motivational messages

- B-007: Skill Time Frame Management
  - Allow setting specific duration for skills
  - Automatic skill archiving/deactivation
  - Reminder system for skill review

- B-008: Data Persistence
  - Save skill data
  - Track historical performance with partial completion support
  - Allow data export/import
  - Save morning routine completions
  - Save rolled over tasks
  - Save memorable moments

- B-009: Advanced Tracking Features
  - Implement detailed analytics
  - Show improvement trends
  - Provide insights into skill progression

- B-010: Interactive Week Calendar Implementation
  - Create InteractiveCalendarView component
  - Implement scrollable week navigation (previous/next week buttons)
  - Highlight current day with purple/blue color scheme
  - Allow date selection to view tasks for that date
  - Display week range (e.g., "Dec 15 - 21")
  - Use purple (#9966E6) and blue (#4D99FF) color palette
  - Make calendar responsive across device sizes

- B-011: Morning Routine Implementation
  - Create MorningRoutineView component
  - Implement 4 specific morning habits:
    * Read 10 pages (purple icon)
    * Stretch (blue icon)
    * Track weight (indigo icon)
    * Drink 500ml water (cyan icon)
  - Support partial and full completion tracking
  - Visual indicators: Light color for partial, dark color for full
  - Grid layout (2 columns)
  - Persist completion data per date

- B-012: Comprehensive Tracking Views
  - Create HabitTrackingGrid component
  - Implement Week View:
    * 7-day grid layout
    * Show completion status per day
    * Color-coded indicators
  - Implement Month View:
    * Calendar grid layout (7 columns, multiple rows)
    * Show all days of month with completion status
    * Highlight current month days
  - Implement Year View:
    * 12-month overview (3 columns, 4 rows)
    * Show completion percentage per month
    * Progress bars for each month
  - Integrate with ProgressTrackingView

- B-013: Task Rollover Mechanism
  - Add rollover property to Skill model
  - Implement rollover functionality in AppState:
    * Track rolled over tasks (skillId -> date)
    * Process rollovers on app start
    * Show rolled over tasks in task list
  - Add rollover button to task cards
  - Visual indicator for rolled over tasks (arrow icon)
  - Automatic cleanup of old rollovers

- B-014: Partial Completion Tracking
  - Update DailyCompletion model to include CompletionLevel enum:
    * .none: No completion
    * .partial: Partial completion (light color)
    * .full: Full completion (dark color)
  - Update task cards to show partial completion state
  - Add partial completion toggle button
  - Update progress views to display partial completions
  - Color coding in all views:
    * Light colors for partial
    * Dark colors for full
    * Gray for none

- B-015: Memorable Moments Feature
  - Create MemorableMoment model with:
    * Title and description
    * Date
    * Category (Achievement, Milestone, Breakthrough, Personal)
    * Optional skill association
  - Add memorable moments storage in AppState
  - Create UI for adding/viewing moments
  - Integrate with progress tracking views
  - Allow filtering by date range and category

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
- Rollover Option: Toggle to allow tasks to rollover to next day if incomplete

### Progress Tracking Screen Specifics
- Git-style heatmap grid showing:
  - Daily/weekly/monthly/yearly completion
  - Color intensity representing completion level:
    * Light colors: Partial completion
    * Dark colors: Full completion
    * Gray: No completion
  - Percentage completion for each skill
  - Ability to tap into detailed skill history
  - Week, Month, and Year view options

### Interactive Calendar Features
- Rolling week calendar on home screen
- Purple/blue color scheme:
  * Primary purple: #9966E6
  * Secondary blue: #4D99FF
  * Accent purple: #B380FF
- Interactive date selection
- Week navigation (previous/next buttons)
- Current day highlighting
- Responsive design for all screen sizes

### Morning Routine Habits
- Four specific habits:
  1. Read 10 pages (purple icon, book.fill)
  2. Stretch (blue icon, figure.flexibility)
  3. Track weight (indigo icon, scalemass)
  4. Drink 500ml water (cyan icon, drop.fill)
- Partial and full completion tracking
- Visual progress indicators
- Daily reset functionality

### Task Rollover Mechanism
- Tasks can be marked for rollover
- Visual indicator (arrow icon) on rolled over tasks
- Automatic processing on app start
- Rolled over tasks appear in next day's task list
- Can be enabled per skill

### Partial Completion Tracking
- Three completion levels:
  - None: No progress (gray)
  - Partial: Some progress (light color)
  - Full: Complete (dark color)
- Visual indicators in all views
- Progress bars show partial completion
- Statistics include partial completion counts

### Memorable Moments
- Record special achievements and milestones
- Categories:
  - Achievement: Completed goals
  - Milestone: Significant progress markers
  - Breakthrough: Major learning moments
  - Personal: Personal reflections
- Date tracking and descriptions
- Optional skill association
- Viewable in progress screens

### Time-Based Greeting Examples
- 5:00 AM - 11:59 AM: "Good Morning"
- 12:00 PM - 5:59 PM: "Good Afternoon"
- 6:00 PM - 4:59 AM: "Good Evening"
- Motivational messages change based on time of day

### Skill Time Frame Options
- Fixed duration skills (e.g., 30-day challenge)
- Recurring skills (daily/weekly/monthly)
- Open-ended skills
- Automatic skill archiving
- Skill review reminders

### Design Aesthetic
- Clean, minimalist design
- Purple/blue color palette throughout
- Responsive layout for all device sizes
- Consistent spacing and typography
- Subtle shadows and rounded corners
- Smooth animations and transitions