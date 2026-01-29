MoveTutor:
; Input: wScriptVar = move ID to teach
; Output: wScriptVar = 0 if learned, -1 if cancelled
	ld a, [wScriptVar]
	ld [wPutativeTMHMMove], a
	ld [wNamedObjectIndex], a
	call GetMoveName
	call CopyName1
	call FadeToMenu
	farcall ChooseMonToLearnTMHM
	jr c, .cancel
	jr .enter_loop

.loop
	farcall ChooseMonToLearnTMHM
	jr c, .cancel
.enter_loop
	call CheckCanLearnTutorMove
	jr nc, .loop
	xor a
	jr .quit

.cancel
	ld a, -1
.quit
	push af
	call ExitAllMenus
	pop af
	ld [wScriptVar], a
	ret

CheckCanLearnTutorMove:
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames
	call GetNickname

	ld a, [wPutativeTMHMMove]
	ld [wCurSpecies], a
	predef CanLearnTMHMMove
	ld a, c
	and a
	jr nz, .can_learn
	push de
	ld de, SFX_WRONG
	call PlaySFX
	pop de
	ld hl, TMHMNotCompatibleText
	call PrintText
	jr .didnt_learn

.can_learn
	callfar KnowsMove
	jr c, .didnt_learn

	predef LearnMove
	ld a, b
	and a
	jr z, .didnt_learn

	ld c, HAPPINESS_LEARNMOVE
	callfar ChangeHappiness

.learned
	scf
	ret

.didnt_learn
	and a
	ret
