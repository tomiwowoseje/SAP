# Skill Tracker App Requirements Document (Updated)

## 1. App Overview
This is an app to help people learn and practice new skills every day. It's for anyone who wants to build good habits, learn something new, or keep track of their progress in different activities. Think of it like a personal coach in your phone that helps you stay motivated and see how far you've come.

**Design Philosophy**: Inspired by HelloHabit's vibrant, card-based design with colorful gradients and intuitive interactions.

## 2. Main Goals
1. Help users set and track daily and weekly skills
2. Make it easy to check off completed tasks
3. Show progress over time with visual color-coded tracking
4. Keep users motivated through streaks and vibrant UI
5. Provide an engaging, aesthetically pleasing user experience

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
- US-010: As a user, I want a color-coded progress tracking system that shows partial and full completions with varying color intensities
- US-011: As a user, I want a consistent HelloHabit-inspired UI design across all screens with vibrant card-based layouts
- US-012: As a user, I want an interactive calendar that shows task completion status with visual indicators
- US-013: As a user, I want to see my streak count for each habit to stay motivated
- US-014: As a user, I want expandable/collapsible category sections to organize my habits

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

- F-010: Color-Coded Progress Tracking
  - What it does: Implement a color intensity system showing task completion levels
  - Color scheme: 
    * Light colors for partial completion
    * Dark colors for full completion
    * Gradient backgrounds for visual appeal
  - Applies across: Home screen cards, progress views, and habit reports
  - Features: Consistent color mapping across all views

- F-011: HelloHabit-Inspired UI Design
  - What it does: Implement card-based design with gradient backgrounds
  - Features:
    * Unique vibrant colors for different habit categories
    * Rounded card design (12-15px corners)
    * Soft gradient backgrounds
    * Clean, modern typography
    * Consistent layout across screens
    * Smooth animations and transitions

- F-012: Streak Tracking System
  - What it does: Track and display consecutive days of habit completion
  - Visual indicator: Fire icon (🔥) with streak count
  - Features:
    * Prominently display streak number on each card
    * Animated/highlighted for motivation
    * Consistent placement on habit cards
    * Streak reset on missed days

- F-013: Expandable Category Sections
  - What it does: Allow users to expand/collapse habit categories
  - Features:
    * Collapsible sections (Morning, Health, etc.)
    * Chevron indicators for expand/collapse state
    * Smooth animation transitions
    * Persistent state across app sessions

## 5. Screens

### S-001: Home Screen (Complete Redesign)
**Overall Layout and Style:**
- Colorful, card-based design inspired by HelloHabit
- Each habit as a full-width, rounded card
- Vibrant, distinct color for each habit category
- Soft, gradient color backgrounds
- Clean, modern typography

**Components:**
1. **Top Navigation Bar**
   - Date/day navigation
   - Fire icon with total streak count (🔥 4)
   - Add habit button (+)
   - Menu button (hamburger)

2. **Interactive Week Calendar**
   - Scrollable week view (Thu-Wed)
   - Connected date bubbles showing progression
   - Highlighted current day (larger, outlined)
   - Purple/blue gradient color scheme
   - Navigation controls (previous/next week)

3. **Habit Cards** (Card-Based Design)
   - **Card Structure:**
     * Full-width rounded cards (12-15px corner radius)
     * Gradient backgrounds matching category color
     * Left-aligned icon (white, category-specific)
     * Habit name (bold, white text)
     * Frequency subtitle (lighter white text)
     * Streak indicator (🔥 number) - top right
     * Interaction buttons - right side (+ or ✓)
   
   - **Example Category Sections** (User-Customizable)
     * Morning Section (Expandable)
       - Section header with sun icon and chevron
       - User-defined morning habits with appropriate category colors
     
     * Health Section (Expandable)
       - Section header with heart icon and chevron
       - User-defined health habits with appropriate category colors
     
     * Other Sections (User-Created)
       - Custom sections based on user's habit organization
       - Each section can have its own icon and color theme

4. **Bottom Navigation**
   - Habits tab (active - purple highlight)
   - Statistics tab (bar chart icon)
   - Settings tab (gear icon)
   - Clean icons with text labels

**Color Palette (Category-Based):**
- Personal Development: Purple (#B57FFF to #9966E6)
- Fitness: Green (#4CAF50 to #388E3C)
- Learning: Orange (#FF9800 to #E68900)
- Health: Teal (#40C4C4 to #2FA6A6)
- Mindfulness: Blue (#4D99FF to #3377DD)
- Creative: Pink (#E91E63 to #C2185B)
- Nutrition: Red (#FF5252 to #DD3333)
- Hydration: Light Blue (#42A5F5 to #1E88E5)
- Custom: Customizable gradient based on user preference

**Interaction Elements:**
- '+' button for adding/incrementing progress
- '✓' checkmark for completed tasks
- Expandable sections (smooth animations)
- Card press for details/editing
- Swipe gestures for quick actions

**Technical Requirements:**
- SwiftUI implementation
- Responsive design for all iPhone sizes
- Smooth 60fps animations
- Accessibility support (VoiceOver, Dynamic Type)
- Dark mode support

**Design to get there:**
- First screen when opening the app
- Clean, minimalist design with vibrant colors
- Priority: Visual appeal and ease of use

### S-002: Add Skill Screen
**What's on the screen:**
- Form to add a new skill with enhanced options
- Category selection (dropdown/list with color indicators)
- Frequency options with visual calendar picker
- Time frame setting (start/end dates)
- Rollover option toggle
- Icon/color selection for card customization

**Design:**
- Match HelloHabit aesthetic
- Preview of habit card as user customizes
- Smooth transitions and animations

**How to get there:** 
- Tap "+" button on home screen
- From settings menu

### S-003: Progress Screen (Habit Reports Redesign)
**Overall Layout:**
- Header: "Habit Reports" with close button (X) and download icon
- View selector: Week / Month / Year tabs (rounded, pill-style)
- Year selector and navigation (< Today >)

**Components:**
1. **View Tabs**
   - Week View (vertical bars icon)
   - Month View (calendar grid icon)
   - Year View (large grid icon - default selected)
   - Selected tab: dark background, white icon/text

2. **Habit Progress Cards**
   Each card shows:
   - Checkmark icon (colored, matching habit)
   - Habit name and goal (e.g., "Drink Water - 8 cups per day")
   - Completion percentage (right-aligned, large)
   - Git-style heatmap grid:
     * Small squares arranged in rows
     * Color intensity shows completion level:
       - Empty/white: No completion
       - Light color: Partial completion
       - Medium color: Good completion
       - Dark/saturated color: Full completion
     * Year view: ~365 squares (52 weeks × 7 days)
     * Organized by weeks/months

3. **Color-Coded Habits**
   Each habit card uses its category color gradient for the heatmap:
   - Personal Development: Purple gradient
   - Fitness: Green gradient
   - Learning: Orange gradient
   - Health: Teal gradient
   - Mindfulness: Blue gradient
   - Creative: Pink gradient
   - Nutrition: Red gradient
   - Hydration: Light blue gradient
   - Custom categories: User-selected gradients

**Year View Specifics:**
- Grid layout: 7 columns (days) × ~52 rows (weeks)
- Compressed vertical view showing full year
- Pattern recognition of completion trends
- Gaps and streaks clearly visible

**Month View Specifics:**
- Calendar grid layout (7 columns, 4-5 rows)
- All days of selected month
- Larger squares than year view
- Current month highlighted

**Week View Specifics:**
- 7-day horizontal or vertical layout
- Large, detailed squares
- Daily notes/details visible
- Easy to see daily patterns

**Interaction:**
- Tap view tabs to switch between Week/Month/Year
- Navigation arrows to change time period
- Scroll to see all habits
- Tap individual squares for daily details
- Tap habit card for detailed breakdown

**Features:**
- Export/import data button (top right)
- Memorable moments integration
- Statistics summary per habit
- Trend analysis indicators

**Design:**
- Light background with subtle shadows
- Consistent with HelloHabit aesthetic
- Clear visual hierarchy
- Smooth tab switching animations

**How to get there:** 
- Tap "Statistics" tab in bottom navigation
- From habit card detail view

### S-004: Settings Screen
**What's on the screen:**
- User preferences
- Notification settings
- Data management (backup/restore)
- Theme selection (Light/Dark/Auto)
- Category management
- About section

**Design:**
- List-based settings interface
- Toggle switches and selection menus
- Matches app color scheme

## 6. Data
- D-001: List of skills with name, frequency, category, color, icon, and tracking details
- D-002: Daily completion status for each skill (with partial completion support)
- D-003: Historical completion data for progress tracking (with color intensity levels)
- D-004: Morning routine completion data (habit ID + date -> completion level)
- D-005: Rolled over tasks (skill ID -> rollover date)
- D-006: Memorable moments (achievements, milestones, personal notes)
- D-007: Streak data per habit (consecutive completion days)
- D-008: Category definitions (name, color gradient, default icon)
- D-009: User preferences (theme, notifications, default views)

## 7. Extra Details
- Needs internet: No (works completely offline)
- Data storage: On the device using Core Data or SwiftData
- Permissions needed: None initially (optional notifications later)
- Dark mode: Yes, support both light and dark modes with adjusted gradients
- Backup option: Allow exporting progress data as JSON/CSV
- Animations: 60fps smooth transitions throughout
- Accessibility: Full VoiceOver support, Dynamic Type, high contrast mode

## 8. Build Steps

### Phase 1: Core Infrastructure
- B-001: Set up SwiftUI project structure with Core Data/SwiftData
- B-002: Implement data models (Habit, DailyCompletion, Category, Streak)
- B-003: Create AppState management system
- B-004: Set up color palette and design system constants

### Phase 2: HelloHabit UI Foundation
- B-005: **HelloHabit UI Redesign - Home Screen**
  - Implement card-based home screen design
  - Create reusable HabitCardView component:
    * Gradient background support
    * Icon + text layout
    * Interaction buttons (+ and ✓)
    * Streak indicator integration
  - Develop gradient background system
  - Create consistent color coding system across categories
  - Implement card animations and transitions
  - Build reusable UI components library

- B-006: **Enhanced Color Tracking System**
  - Implement color intensity tracking in data model
  - Create CompletionLevel enum (none, partial, medium, full)
  - Build color mapping for completion levels:
    * None: Empty/white
    * Partial: 30% saturation
    * Medium: 60% saturation
    * Full: 100% saturation
  - Update all progress views with new color system
  - Create color interpolation functions
  - Implement accessibility color adjustments

### Phase 3: Home Screen Implementation
- B-007: **Top Navigation Bar**
  - Time-based greeting feature
  - Current date display
  - Streak counter with fire icon
  - Add habit button
  - Menu/settings button

- B-008: **Interactive Week Calendar**
  - Create InteractiveCalendarView component
  - Implement scrollable week navigation
  - Connected bubble design with lines
  - Highlight current day (larger, outlined)
  - Date selection functionality
  - Purple/blue gradient styling
  - Week range display
  - Make responsive across device sizes

- B-009: **Expandable Category Sections**
  - Create CategorySectionView component
  - Implement expand/collapse functionality
  - Chevron indicator animations
  - Section header with icon
  - Persistent state management
  - Smooth height animations

- B-010: **Habit Card Components**
  - Build base HabitCardView with:
    * Gradient backgrounds (category-specific)
    * Icon and text layout
    * Frequency subtitle
    * Streak indicator position
    * Interaction button placement
  - Implement card press gestures
  - Add swipe actions for quick edit/delete
  - Create card shadow and border styling

- B-011: **Morning Routine Implementation**
  - Refactor as expandable category section
  - Implement 4 specific morning habits
  - Support partial and full completion
  - Visual indicators with color coding
  - Grid layout within section
  - Persist completion data per date

- B-012: **Streak Tracking System**
  - Create Streak data model
  - Implement streak calculation logic:
    * Count consecutive completion days
    * Reset on missed days
    * Handle partial completions
  - Build streak display component
  - Fire icon with count
  - Animation for streak milestones
  - Integrate with habit cards

- B-013: **Bottom Navigation**
  - Habits tab (default)
  - Statistics tab
  - Settings tab
  - Active state styling (purple highlight)
  - Icon + label design
  - Tab switching transitions

### Phase 4: Progress Tracking Screen
- B-014: **Comprehensive Tracking Views - Base Structure**
  - Create HabitReportsView component
  - Implement view selector (Week/Month/Year tabs)
  - Build navigation controls (< Today >)
  - Year selector functionality
  - Download/export button

- B-015: **Git-Style Heatmap Component**
  - Create HeatmapGridView component
  - Implement square grid layout system:
    * Calculate grid dimensions (7 cols × N rows)
    * Handle different view densities
    * Responsive sizing
  - Color intensity visualization:
    * Map completion levels to colors
    * Support category-specific gradients
    * Handle empty states
  - Tap gesture for daily details
  - Accessibility labels for screen readers

- B-016: **Year View Implementation**
  - 52-week × 7-day grid layout
  - Compressed vertical scrolling
  - Week separators
  - Month labels
  - Performance optimization for 365+ squares
  - Pattern recognition visualization

- B-017: **Month View Implementation**
  - Calendar grid layout (7×5)
  - Current month highlighting
  - Day number labels
  - Larger squares than year view
  - Previous/next month navigation
  - Weekend highlighting

- B-018: **Week View Implementation**
  - 7-day detailed layout
  - Large squares with details
  - Daily completion notes
  - Goal progress indicators
  - Day labels and headers
  - Quick edit functionality

- B-019: **Habit Progress Cards**
  - Create HabitProgressCardView
  - Integrate heatmap into card
  - Show habit icon and name
  - Display goal description
  - Completion percentage (large, right-aligned)
  - Category color coding
  - Tap for detailed breakdown

### Phase 5: Skill Management
- B-020: **Comprehensive Skill Input**
  - Design skill creation screen
  - Category selection with color preview
  - Frequency options with visual picker
  - Time frame setting (date pickers)
  - Icon selection gallery
  - Color gradient customization
  - Live card preview
  - Rollover option toggle

- B-021: **Skill Management System**
  - Edit existing skills functionality
  - Delete skills with confirmation
    - Adjust skill parameters
  - Enable/disable skills
  - Reorder skills (drag and drop)
  - Archive completed skills

- B-022: **Category Management**
  - Predefined categories with gradients:
    * Personal Development (Purple #B57FFF to #9966E6)
    * Fitness (Green #4CAF50 to #388E3C)
    * Learning (Orange #FF9800 to #E68900)
    * Health (Teal #40C4C4 to #2FA6A6)
    * Mindfulness (Blue #4D99FF to #3377DD)
    * Creative (Pink #E91E63 to #C2185B)
    * Nutrition (Red #FF5252 to #DD3333)
    * Hydration (Light Blue #42A5F5 to #1E88E5)
    * Custom categories (user-defined)
  - Category creation interface
  - Color gradient editor
  - Icon selection per category
  - Group skills by categories on home screen
  - Allow users to create unlimited custom categories
  - Category reordering and archiving

### Phase 6: Advanced Features
- B-023: **Task Rollover Mechanism**
  - Add rollover property to Habit model
  - Rollover tracking in AppState
  - Process rollovers on app start
  - Visual rollover indicator (arrow)
  - Rollover button on cards
  - Automatic cleanup of old rollovers

- B-024: **Partial Completion Tracking**
  - Update DailyCompletion model
  - CompletionLevel enum implementation
  - Partial completion toggle UI
  - Progress bar for partial states
  - Color coding in all views:
    * Light: Partial
    * Dark: Full
    * Empty: None
  - Statistics with partial counts

- B-025: **Memorable Moments Feature**
  - Create MemorableMoment model
  - Categories (Achievement, Milestone, etc.)
  - Add moments UI from progress screens
  - Moments gallery view
  - Date and skill association
  - Filtering and search
  - Integration with progress tracking

- B-026: **Skill Time Frame Management**
  - Set skill duration (30-day challenge, etc.)
  - Automatic archiving on completion
  - Skill review reminders
  - Progress notifications
  - Time-limited vs ongoing tracking

### Phase 7: Data and Settings
- B-027: **Data Persistence**
  - Core Data/SwiftData setup
  - Save all habit data
  - Track historical performance
  - Morning routine completions
  - Rolled over tasks
  - Memorable moments
  - Streak data
  - User preferences

- B-028: **Settings Implementation**
  - User preferences interface
  - Theme selection (Light/Dark/Auto)
  - Notification settings
  - Data backup/restore
  - Export to JSON/CSV
  - Import from backup
  - Category management access
  - About/credits section

- B-029: **Advanced Analytics**
  - Detailed statistics per habit
  - Improvement trends
  - Best/worst day analysis
  - Time of day patterns
  - Category performance
  - Weekly/monthly summaries
  - Goal achievement rates

### Phase 8: Polish and Optimization
- B-030: **Animations and Transitions**
  - Card appearance animations
  - Checkmark completion animation
  - Streak milestone celebrations
  - Tab switching transitions
  - Expand/collapse animations
  - Loading states
  - Smooth 60fps throughout

- B-031: **Accessibility Features**
  - VoiceOver support for all elements
  - Dynamic Type implementation
  - High contrast mode
  - Reduce motion support
  - Color blind friendly alternatives
  - Haptic feedback

- B-032: **Performance Optimization**
  - Lazy loading for large datasets
  - Efficient grid rendering
  - Image caching
  - Background data processing
  - Memory management
  - Battery optimization

- B-033: **Testing and Refinement**
  - Unit tests for data models
  - UI tests for critical paths
  - Performance testing
  - Accessibility audit
  - User testing feedback
  - Bug fixes and polish

## 9. Technical Architecture

### SwiftUI Components Structure
```
Views/
├── ContentView.swift (Main container)
├── Home/
│   ├── HomeView.swift
│   ├── InteractiveCalendarView.swift
│   ├── HabitCardView.swift
│   ├── CategorySectionView.swift
│   └── StreakIndicatorView.swift
├── Progress/
│   ├── HabitReportsView.swift
│   ├── HeatmapGridView.swift
│   ├── YearView.swift
│   ├── MonthView.swift
│   ├── WeekView.swift
│   └── HabitProgressCardView.swift
├── AddSkill/
│   ├── AddSkillView.swift
│   ├── CategoryPickerView.swift
│   ├── IconPickerView.swift
│   └── ColorGradientPicker.swift
└── Settings/
    └── SettingsView.swift

Models/
├── Habit.swift
├── DailyCompletion.swift
├── Category.swift
├── Streak.swift
├── MemorableMoment.swift
└── UserPreferences.swift

ViewModels/
└── AppState.swift

Utilities/
├── ColorPalette.swift
├── DateHelper.swift
├── StreakCalculator.swift
└── CompletionTracker.swift
```

### Design System
**Typography:**
- Headers: SF Pro Display, Bold, 24-28pt
- Body: SF Pro Text, Regular, 16-17pt
- Captions: SF Pro Text, Medium, 13-14pt

**Spacing:**
- Card padding: 16px
- Section spacing: 24px
- Element spacing: 8-12px
- Screen margins: 16-20px

**Corner Radius:**
- Cards: 12-15px
- Buttons: 8-10px
- Small elements: 6px

**Shadows:**
- Card shadow: 0 2px 8px rgba(0,0,0,0.1)
- Active shadow: 0 4px 12px rgba(0,0,0,0.15)

## 10. Priority Implementation Order
1. **Phase 1-2**: Core infrastructure and UI foundation (Weeks 1-2)
2. **Phase 3**: Home screen with basic functionality (Weeks 3-4)
3. **Phase 4**: Progress tracking screen (Weeks 5-6)
4. **Phase 5**: Skill management (Week 7)
5. **Phase 6**: Advanced features (Weeks 8-9)
6. **Phase 7**: Data and settings (Week 10)
7. **Phase 8**: Polish and optimization (Weeks 11-12)

## 11. Success Metrics
- User engagement: Daily active usage
- Completion rates: % of tasks completed
- Retention: Users returning after 7/30 days
- Streak longevity: Average streak length
- Feature usage: Most used features
- User satisfaction: App store ratings

## 12. Future Enhancements (Post-Launch)
- Social features (share progress)
- Habit suggestions based on AI
- Apple Watch companion app
- Widgets for iOS home screen
- Siri shortcuts integration
- iCloud sync across devices
- Premium features (advanced analytics)
- Custom themes and icon packs
