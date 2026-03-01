# LiftStat - a personal weightlifting tracker

LiftStat is a personal weightlifting tracker that helps you log your lifts and progression over time. LiftStat's primary purpose is to serve the "Feedback Loop" to make it fast and easy to log workouts. After working out (or when a user isn't working out) LiftStat is used to show progression, key lifts, per-muscle group load, and other useful metrics. This information is exportable to easily share with friends who don't use the app as a picture.

## Feedback Loop - Details

The Feedback Loop is the main interaction loop of the application. When the app is opened, the user is presented with an option to start a workout. If the user has an active workout plan, the correct day is displayed. Additionally, even when there is no workout plan saved, the user can select to create a freeform workout which enabled ad-hoc tracking of exercises. Once in a workout, the user quickly inputs the weight and reps of a lift. Each set is shown in rows under the exercise's header. If a user enters a PR based on the estimated 1 rep max using the epley formula, then a celebration animation plays (which does not block the user from inputting information) to encourage progression.

There are two separate flows for planned and freeform workouts:

### Flow for a planned workout
1. The user selects "Start X Day" where X is the type of day planned (e.g.: push, pull, legs, chest, back, upper, lower, etc).
2. The exercises which have been programmed into the template are pre-populated in the active workout view
3. There are "ghost" numbers shown for the last logged weight and reps of an exercise
4. The cursor focus immediately moves to the first exercise to aid in inputting numbers
5. The user incrementally confirms weight and reps of their exercises
6. Upon completion, the user confirms that the workout is over
7. A post-workout summary is shown which shows duration, volume, key lifts, and other useful/interesting statistics about this workout.

### Flow for a freeform workout
1. The user selects "Start Freeform Workout"
2. The user is shown an option to "Add Exercise" which brings up a selector when clicked to choose an exercise. Exercises are grouped by muscle group and subdivided by "Barbell, Dumbell, Cable, Machine, Bodyweight" in that order
3. There are "ghost" numbers shown for the last logged weight and reps of an exercise
4. The cursor focus immediately moves to the first exercise to aid in inputting numbers
5. The user incrementally confirms weight and reps of their exercises
6. Upon completion, the user confirms that the workout is over
7. A post-workout summary is shown which shows duration, volume, key lifts, and other useful/interesting statistics about this workout.

## Active Workout View

The active workout view is the primary view for working out. The user will be able to see the current day (if in a planned routine), the elapsed time, and the overview of the work done for this workout.

## Workout Summary View

The workout summary view shows after a workout has been completed, and it recaps the information entered during the active workout. It is the terminal state for a workout. It shows: muscle groups worked, volume, PRs and 1RM estimations, and weight progressions compared to previous lifts. It also has an option to share the workout with friends (see "Sharing Workouts" section for more).

## Log View

The log view contains all historical data about exercises and workouts performed. The log view contains all timeseries metrics for progression, individual lift PRs, and anything that is useful for tracking progressive overload. It also can identify lacking areas or stagnation. The log view is not expected to be used when actively working out, but it is expected to be viewed either afterwards or when not in the gym. Information can also be shared with others (see "Sharing Workouts")

## Exercise Bank

There is a default set of extensive exercises grouped by muscle group and subdivided by "barbell, dumbell, cable, machine, bodyweight" in that order. The user can add additional exercises to this exercise bank for use in a workout. Modifying and adding exercises to the bank should be possible during the active workout view, in case something needs to be added. When an exercise is added during the active workout view, we collect minimal information about the exercise. After the workout is complete, the information can be expanded upon in the post-workout summary.

## Sharing Workouts

The application should be able to export the information present in the workout summary or log view for sharing with friends. The application can generate a picture which is sent to others that has the information present on it. This will be used to show off the exercises, and should only lightly reference liftstat. It is *not* a CTA or a way to gather more users.
