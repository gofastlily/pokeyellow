HiddenItemNear:
	ld hl, HiddenItemCoords
	ld b, 0
.loop
	ld de, 3
	ld a, [wCurMap]
	call IsInRestOfArray
	ret nc ; return if current map has no hidden items
	push bc
	push hl
	ld hl, wObtainedHiddenItemsFlags
	ld c, b
	ld b, FLAG_TEST
	predef FlagActionPredef
	ld a, c
	pop hl
	pop bc
	inc b
	and a
	inc hl
	ld d, [hl]
	inc hl
	ld e, [hl]
	inc hl
	jr nz, .loop ; if the item has already been obtained
; check if the item is within 4-5 tiles (depending on the direction of item)
	ld a, [wYCoord]
	call Sub5ClampTo0
	cp d
	jr nc, .loop
	ld a, [wYCoord]
	add 4
	cp d
	jr c, .loop
	ld a, [wXCoord]
	call Sub5ClampTo0
	cp e
	jr nc, .loop
	ld a, [wXCoord]
	add 5
	cp e
	jr c, .loop
	call DoItemFinderFacing
	scf
	ret

Sub5ClampTo0:
; subtract 5 but clamp to 0
	sub 5
	cp $f0
	ret c
	xor a
	ret


DoItemFinderFacing:
; input: d = hidden item's y coord, e = hidden item's x coord
    ld bc, 0

; e = how far away in x direction the item is
    ld a, [wXCoord]
    sub e
    jr nc, .got_dx
    cpl
    inc a
    inc c
.got_dx
    ld e, a

; a = how far away in y direction the item is
    ld a, [wYCoord] ; player's y coord
    sub d ; subtract hidden item's y value
    jr nc, .got_dy
    cpl
    inc a
    inc b
.got_dy

    sub e
    jr nc, .up_or_down
; left or right
    ld a, c
    and a
    ld a, PLAYER_DIR_LEFT
    jr z, .done
    assert PLAYER_DIR_LEFT >> 1 == PLAYER_DIR_RIGHT
    rrca ; ld a, PLAYER_DIR_RIGHT
    jr .done

.up_or_down
    ld a, b
    and a
    ld a, PLAYER_DIR_UP
    jr z, .done
    assert PLAYER_DIR_UP >> 1 == PLAYER_DIR_DOWN
    rrca ; ld a, PLAYER_DIR_DOWN
    ; fallthrough
.done
    ld [wPlayerMovingDirection], a
    ret
