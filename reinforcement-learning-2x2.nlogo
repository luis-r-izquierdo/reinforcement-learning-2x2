;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GNU GENERAL PUBLIC LICENSE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ReinforcementLearning2x2
;; ReinforcementLearning2x2 is an agent-based model where two
;; reinforcement learners play a 2x2 game.
;; Copyright (C) 2008 Luis R. Izquierdo & Segismundo S. Izquierdo
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
;;
;; Contact information:
;; Luis R. Izquierdo
;;   University of Burgos, Spain.
;;   e-mail: lrizquierdo@ubu.es

;;;;;;;;;;;;;;;;;
;;; VARIABLES ;;;
;;;;;;;;;;;;;;;;;

globals [
  outcome
]

patches-own [cum-visits]

;;;;;;;;;;;;;;
;;; BREEDS ;;;
;;;;;;;;;;;;;;

breed [players player]
breed [prob-points prob-point]

players-own [
  aspiration

  payoff-CC
  payoff-CD
  payoff-DC
  payoff-DD
  payoff

  prop-cooperate
  prob-step
  cooperate?
]

;;;;;;;;;;;;;;;;;;;
;;; MODEL SETUP ;;;
;;;;;;;;;;;;;;;;;;;

to startup
  clear-all
  ask patches [set pcolor white]
  setup-players
  setup-prob-point
  refresh-parameters
  reset-ticks
  update-graphs
end

to setup-players
  create-players 2 [set hidden? true]
  ask player 0 [
    set prob-step (1 / (world-height - 1))
    set prop-cooperate (round (initial-prop-coop-P1 * (world-height - 1))) * prob-step
  ]
  ask player 1 [
    set prob-step (1 / (world-width - 1))
    set prop-cooperate (round (initial-prop-coop-P2 * (world-width - 1))) * prob-step
  ]
end

to setup-prob-point
  create-prob-points 1 [
    set shape "circle"
    set color red
  ]
end

;;;;;;;;;;;;;;;;;;;;;;
;;; MAIN PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;

to go
  refresh-parameters
  ask players [decide-action]
  update-payoffs
  ask players [update-prop-cooperate]
  tick
  update-graphs
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PLAYERS' PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

to decide-action
  set cooperate? ifelse-value ((random-float 1.0) <= prop-cooperate) [true] [false]
  if (random-float 1.0) <= trembling-hands-noise [set cooperate? (not cooperate?)]
end

to update-prop-cooperate
  set prop-cooperate
    (prop-cooperate + prob-step *
    (ifelse-value (payoff < aspiration) [-1] [1]) *
    (ifelse-value cooperate? [1] [-1]))
  if prop-cooperate < 0 [set prop-cooperate 0]
  if prop-cooperate > 1 [set prop-cooperate 1]
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; PAYOFF UPDATING ;;;
;;;;;;;;;;;;;;;;;;;;;;;

to update-payoffs
 ifelse [cooperate?] of player 0
   [ifelse ([cooperate?] of player 1)
      [
        ask players [set payoff payoff-CC]
        ask prob-points [set label "CC"]
      ]
      [
        ask players [set payoff payoff-CD]
        ask prob-points [set label "CD"]
      ]
   ]
   [ifelse ([cooperate?] of player 1)
      [
        ask players [set payoff payoff-DC]
        ask prob-points [set label "DC"]
      ]
      [
        ask players [set payoff payoff-DD]
        ask prob-points [set label "DD"]
      ]
   ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GRAPHS AND DATA GATHERING ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-graphs
  ask prob-points [update-location]
  update-patch-colors
  my-update-plots
end

to update-location
  set ycor ([prop-cooperate] of player 0) * (world-height - 1)
  set xcor ([prop-cooperate] of player 1) * (world-width - 1)
  set cum-visits (cum-visits + 1)
end

to update-patch-colors
  let min-visits min [cum-visits] of patches
  let max-visits max [cum-visits] of patches
  if (max-visits != min-visits) [
    ask patches [set pcolor (103 + 6.99 * ((max-visits - cum-visits) / (max-visits - min-visits)) ^ 64)]
        ;; I raise to the power of 64 to make the colour scale finer
        ;; when cum-visits is close to min-visits.
        ;; Using 7 rather than 6.99 can cause patches that should be white turn black
  ]
end

to my-update-plots
  set-current-plot "Propensities to cooperate"
  set-current-plot-pen "Player 1"
  plotxy ticks [prop-cooperate] of player 0
  set-current-plot-pen "Player 2"
  plotxy ticks [prop-cooperate] of player 1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; REFRESHING PARAMETERS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This is to allow for run-time interaction

to refresh-parameters
  ask turtle 0 [
    set payoff-CC CC-P1
    set payoff-CD CD-P1
    set payoff-DC DC-P1
    set payoff-DD DD-P1
    set aspiration aspiration-P1
  ]
  ask turtle 1 [
    set payoff-CC CC-P2
    set payoff-CD CD-P2
    set payoff-DC DC-P2
    set payoff-DD DD-P2
    set aspiration aspiration-P2
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
419
10
664
262
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
16
0
16
1
1
1
ticks
30.0

INPUTBOX
89
50
139
110
CC-P1
3
1
0
Number

INPUTBOX
141
50
191
110
CC-P2
3
1
0
Number

INPUTBOX
90
122
140
182
DC-P1
4
1
0
Number

INPUTBOX
142
122
192
182
DC-P2
0
1
0
Number

INPUTBOX
209
51
259
111
CD-P1
0
1
0
Number

INPUTBOX
262
51
312
111
CD-P2
4
1
0
Number

INPUTBOX
208
122
258
182
DD-P1
1
1
0
Number

INPUTBOX
262
122
312
182
DD-P2
1
1
0
Number

TEXTBOX
182
13
238
31
Player 2 \n
12
35.0
1

TEXTBOX
13
106
60
124
Player 1
12
105.0
1

TEXTBOX
65
73
80
91
C
12
55.0
1

TEXTBOX
66
143
81
161
D
12
15.0
1

TEXTBOX
137
28
152
46
C
12
55.0
1

TEXTBOX
258
29
281
47
D
12
15.0
1

INPUTBOX
276
216
364
276
aspiration-P2
0.5
1
0
Number

INPUTBOX
156
216
241
276
aspiration-P1
0.5
1
0
Number

TEXTBOX
15
14
122
32
PAYOFF MATRIX
13
0.0
1

TEXTBOX
13
226
110
264
ASPIRATION THRESHOLDS
13
0.0
1

TEXTBOX
180
198
236
216
Player 1
12
105.0
1

TEXTBOX
301
199
363
217
Player 2
12
35.0
1

PLOT
419
289
652
439
Propensities to cooperate
time-step
Propensities
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Player 1" 1.0 0 -13345367 true "" ""
"Player 2" 1.0 0 -6459832 true "" ""

INPUTBOX
142
281
250
341
initial-prop-coop-P1
0.875
1
0
Number

INPUTBOX
266
282
375
342
initial-prop-coop-P2
0.675
1
0
Number

TEXTBOX
12
284
131
338
INITIAL PROPENSITIES TO COOPERATE
13
0.0
1

BUTTON
153
403
208
436
Setup
startup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
214
403
273
436
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
277
403
332
436
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
187
351
376
384
trembling-hands-noise
trembling-hands-noise
0
0.5
0
0.01
1
NIL
HORIZONTAL

TEXTBOX
15
184
398
202
-------------------------------------------------------------------------------------------
11
0.0
1

TEXTBOX
458
268
634
286
Propensity to cooperate Player 2
10
0.0
1

TEXTBOX
368
99
417
167
Prop. to coop. Player 1
10
0.0
1

TEXTBOX
13
350
157
384
TREMBLING HANDS NOISE
13
0.0
1

TEXTBOX
14
386
393
404
-------------------------------------------------------------------------------------------
11
0.0
1

TEXTBOX
13
410
141
428
SETUP AND RUN
14
12.0
1

@#$#@#$#@
## WHAT IS IT?

reinforcement-learning-2x2 is an agent-based model where two reinforcement learners play a 2x2 game. Reinforcement learners use their experience to choose or avoid certain actions based on the observed consequences. Actions that led to satisfactory outcomes (i.e. outcomes that met or exceeded aspirations) in the past tend to be repeated in the future, whereas choices that led to unsatisfactory experiences are avoided.

## HOW IT WORKS

In this model there are two reinforcement learners playing a 2x2 game repeatedly. Each player r (r = 1,2) has a certain propensity to cooperate p(r,C) and a certain propensity to defect p(r,D); these propensities are always multiples of 1/(world-height - 1) for player 1 and multiples of 1/(world-width - 1) for player 2. In the absence of noise, players cooperate with probability p(r,C) and defect with probability p(r,D), but they may also suffer from "trembling hands", i.e. after having decided which action to undertake, each player r may select the wrong action with probability trembling-hands-noise.

The revision of propensities takes place following a reinforcement learning approach: players increase their propensity of undertaking a certain action if it led to payoffs above their aspiration level A(r), and decrease this propensity otherwise. Specifically, if a player r receives a payoff greater or equal to her aspiration threshold A(r), she increments the propensity of conducting the selected action in 1/(world-height - 1) if r = 1 or in 1/(world-width - 1) if r = 2 (within the natural limits of probabilities). Otherwise she decreases this propensity in the same quantity. The updated propensity for the action not selected derives from the constraint that propensities must add up to one.

## HOW TO USE IT

The view is used here to represent players' propensities to cooperate, with player 1's propensity to cooperate in the vertical axis and player 2's propensity to cooperate in the horizontal axis. The red circle represents the current state of the system and its label (CC, CD, DC, or DD) denotes the last outcome that occurred. Patches are coloured in shades of blue according to the number of times that the system has visited the state they represent: the higher the number of visits, the darker the shade of blue. The plot beneath the representation of the state space shows the time series of both players' propensity to cooperate.

## CREDITS AND REFERENCES

Copyright (C) 2008 Luis R. Izquierdo & Segismundo S. Izquierdo
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>startup</setup>
    <go>go</go>
    <timeLimit steps="1000000"/>
    <metric>map [[cum-visits] of ?] sort patches</metric>
    <enumeratedValueSet variable="trembling-hands-noise">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CD-P2">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-prop-coop-P2">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DD-P1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CD-P1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CC-P1">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CC-P2">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="aspiration-P2">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DC-P1">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DD-P2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="aspiration-P1">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-prop-coop-P1">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DC-P2">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
