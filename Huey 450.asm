
_Interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;Huey 450.mbas,81 :: 		Sub Procedure Interrupt()      'Called every 20ms by TMR0
;Huey 450.mbas,82 :: 		CriticalProcess = 1       'Set the indicator to 1, this will overwrite the
	MOVLW      1
	MOVWF      _CriticalProcess+0
;Huey 450.mbas,86 :: 		GPIO.B5 = 1               'Make Pin5 go high, start of servo pulse.
	BSF        GPIO+0, 5
;Huey 450.mbas,88 :: 		if Smoother = 0 then      'Choose the best initial delay
	MOVF       _Smoother+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt2
;Huey 450.mbas,89 :: 		Delay_us(900)          'to ensure the servo is as close to
	MOVLW      2
	MOVWF      R12+0
	MOVLW      41
	MOVWF      R13+0
L__Interrupt4:
	DECFSZ     R13+0, 1
	GOTO       L__Interrupt4
	DECFSZ     R12+0, 1
	GOTO       L__Interrupt4
	NOP
	NOP
L__Interrupt2:
;Huey 450.mbas,91 :: 		if Smoother = 1 then      'The reason the first position is
	MOVF       _Smoother+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt6
;Huey 450.mbas,92 :: 		Delay_us(1170)       '900us and not 1000us is that these
	MOVLW      2
	MOVWF      R12+0
	MOVLW      131
	MOVWF      R13+0
L__Interrupt8:
	DECFSZ     R13+0, 1
	GOTO       L__Interrupt8
	DECFSZ     R12+0, 1
	GOTO       L__Interrupt8
	NOP
	NOP
L__Interrupt6:
;Huey 450.mbas,94 :: 		if Smoother = 2 then      'execute themselves. This needs to be
	MOVF       _Smoother+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt10
;Huey 450.mbas,95 :: 		Delay_us(1440)       'accounted for.
	MOVLW      2
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L__Interrupt12:
	DECFSZ     R13+0, 1
	GOTO       L__Interrupt12
	DECFSZ     R12+0, 1
	GOTO       L__Interrupt12
	NOP
	NOP
L__Interrupt10:
;Huey 450.mbas,97 :: 		if Smoother = 3 then      '0%  25%  50%  75%  100%
	MOVF       _Smoother+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt14
;Huey 450.mbas,98 :: 		Delay_us(1710)       'So, 32% would be 25% + a 7% for next Delay.
	MOVLW      3
	MOVWF      R12+0
	MOVLW      55
	MOVWF      R13+0
L__Interrupt16:
	DECFSZ     R13+0, 1
	GOTO       L__Interrupt16
	DECFSZ     R12+0, 1
	GOTO       L__Interrupt16
L__Interrupt14:
;Huey 450.mbas,100 :: 		if Smoother = 4 then
	MOVF       _Smoother+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt18
;Huey 450.mbas,101 :: 		Delay_us(1980)
	MOVLW      3
	MOVWF      R12+0
	MOVLW      145
	MOVWF      R13+0
L__Interrupt20:
	DECFSZ     R13+0, 1
	GOTO       L__Interrupt20
	DECFSZ     R12+0, 1
	GOTO       L__Interrupt20
L__Interrupt18:
;Huey 450.mbas,105 :: 		for DelayCounter  = 1 to Delay
	MOVLW      1
	MOVWF      _DelayCounter+0
	CLRF       _DelayCounter+1
L__Interrupt21:
	MOVLW      128
	XORWF      _Delay+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORWF      _DelayCounter+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt212
	MOVF       _DelayCounter+0, 0
	SUBWF      _Delay+0, 0
L__Interrupt212:
	BTFSS      STATUS+0, 0
	GOTO       L__Interrupt25
;Huey 450.mbas,108 :: 		Next DelayCounter
	MOVF       _DelayCounter+1, 0
	XORWF      _Delay+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt213
	MOVF       _Delay+0, 0
	XORWF      _DelayCounter+0, 0
L__Interrupt213:
	BTFSC      STATUS+0, 2
	GOTO       L__Interrupt25
	INCF       _DelayCounter+0, 1
	BTFSC      STATUS+0, 2
	INCF       _DelayCounter+1, 1
	GOTO       L__Interrupt21
L__Interrupt25:
;Huey 450.mbas,110 :: 		GPIO.B5 = 0               'The pulse is over, drop the signal
	BCF        GPIO+0, 5
;Huey 450.mbas,111 :: 		CriticalProcess = 0       'Reset the indicator back to Zero.
	CLRF       _CriticalProcess+0
;Huey 450.mbas,112 :: 		TMR0 = 178                'Reset the Timer (19.968 ms until next call)
	MOVLW      178
	MOVWF      TMR0+0
;Huey 450.mbas,113 :: 		INTCON = %10100000        'Reset the Flags and restart the
	MOVLW      160
	MOVWF      INTCON+0
;Huey 450.mbas,115 :: 		End Sub
L_end_Interrupt:
L__Interrupt211:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _Interrupt

_PulseCounter:

;Huey 450.mbas,118 :: 		dim tmp as word                         'Temporary variable
;Huey 450.mbas,119 :: 		tmp  = 0                                'Clear temporary variable
	CLRF       R3+0
	CLRF       R3+1
;Huey 450.mbas,126 :: 		while TestBit(Port, PortBit) = 0        'Wait for falling edge of pulse
L__PulseCounter28:
	MOVF       FARG_PulseCounter_PortBit+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__PulseCounter215:
	BTFSC      STATUS+0, 2
	GOTO       L__PulseCounter216
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__PulseCounter215
L__PulseCounter216:
	MOVF       FARG_PulseCounter_Port+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	ANDWF      INDF+0, 0
	MOVWF      R2+0
	CLRF       R1+0
	MOVF       R2+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L__PulseCounter32
	MOVLW      1
	MOVWF      R1+0
L__PulseCounter32:
	MOVF       R1+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L__PulseCounter28
;Huey 450.mbas,129 :: 		CriticalProcess = 2                     'Set the critical process indicator
	MOVLW      2
	MOVWF      _CriticalProcess+0
;Huey 450.mbas,130 :: 		while TestBit(Port, PortBit) = 1        'Wait for falling edge
L__PulseCounter34:
	MOVF       FARG_PulseCounter_PortBit+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__PulseCounter217:
	BTFSC      STATUS+0, 2
	GOTO       L__PulseCounter218
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__PulseCounter217
L__PulseCounter218:
	MOVF       FARG_PulseCounter_Port+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	ANDWF      INDF+0, 0
	MOVWF      R2+0
	CLRF       R1+0
	MOVF       R2+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L__PulseCounter38
	MOVLW      1
	MOVWF      R1+0
L__PulseCounter38:
	MOVF       R1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__PulseCounter35
;Huey 450.mbas,131 :: 		Inc(tmp)                                'Count the number of times I get to
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
;Huey 450.mbas,132 :: 		wend                                    'test the port before the low signal.
	GOTO       L__PulseCounter34
L__PulseCounter35:
;Huey 450.mbas,133 :: 		If CriticalProcess <> 2 then            'Interupt must have occured during
	MOVF       _CriticalProcess+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L__PulseCounter40
;Huey 450.mbas,134 :: 		Exit                                  'the reading, thus the count will be
	GOTO       L_end__PulseCounter
L__PulseCounter40:
;Huey 450.mbas,137 :: 		CriticalProcess = 0                     'so we use a low counter also.
	CLRF       _CriticalProcess+0
;Huey 450.mbas,140 :: 		if tmp <29 then                         'Low signal detected
	MOVLW      0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__PulseCounter219
	MOVLW      29
	SUBWF      R3+0, 0
L__PulseCounter219:
	BTFSC      STATUS+0, 0
	GOTO       L__PulseCounter43
;Huey 450.mbas,141 :: 		if RxSwitchCounter < 3 then         'Must have 4 low signals in a row
	MOVLW      3
	SUBWF      _RxSwitchCounter+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L__PulseCounter46
;Huey 450.mbas,142 :: 		inc(RxSwitchCounter)             'to take into account the Interrupt.
	INCF       _RxSwitchCounter+0, 1
	GOTO       L__PulseCounter47
;Huey 450.mbas,143 :: 		Else
L__PulseCounter46:
;Huey 450.mbas,144 :: 		RxSwitchCounter = 0
	CLRF       _RxSwitchCounter+0
;Huey 450.mbas,145 :: 		RxSwitch = 0                    'less than 29 is a good low signal.
	BCF        _RxSwitch+0, BitPos(_RxSwitch+0)
;Huey 450.mbas,146 :: 		End If
L__PulseCounter47:
L__PulseCounter43:
;Huey 450.mbas,148 :: 		if tmp >=29 then                       'Dont worry about the Interrupt for a
	MOVLW      0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__PulseCounter220
	MOVLW      29
	SUBWF      R3+0, 0
L__PulseCounter220:
	BTFSS      STATUS+0, 0
	GOTO       L__PulseCounter49
;Huey 450.mbas,149 :: 		RxSwitch = 1                       'high signal, not possible situation.
	BSF        _RxSwitch+0, BitPos(_RxSwitch+0)
;Huey 450.mbas,150 :: 		RxSwitchCounter = 0                'Greater than 29 is a good High signal.
	CLRF       _RxSwitchCounter+0
L__PulseCounter49:
;Huey 450.mbas,152 :: 		end sub
L_end__PulseCounter:
L_end_PulseCounter:
	RETURN
; end of _PulseCounter

_DisplayValueLED:

;Huey 450.mbas,173 :: 		Dim Temp as Word
;Huey 450.mbas,174 :: 		If P1 = 999 then   'Just flash LEDs, program executed the call instruction.
	MOVF       FARG_DisplayValueLED_P1+1, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED222
	MOVLW      231
	XORWF      FARG_DisplayValueLED_P1+0, 0
L__DisplayValueLED222:
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED53
;Huey 450.mbas,175 :: 		For i = 1 to 60
	MOVLW      1
	MOVWF      _i+0
L__DisplayValueLED56:
;Huey 450.mbas,176 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED223:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED224
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED223
L__DisplayValueLED224:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,177 :: 		Delay_ms(25)
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L__DisplayValueLED60:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED60
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED60
	NOP
;Huey 450.mbas,178 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED225:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED226
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED225
L__DisplayValueLED226:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,179 :: 		Delay_ms(25)
	MOVLW      33
	MOVWF      R12+0
	MOVLW      118
	MOVWF      R13+0
L__DisplayValueLED61:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED61
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED61
	NOP
;Huey 450.mbas,180 :: 		Next i
	MOVF       _i+0, 0
	XORLW      60
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED59
	INCF       _i+0, 1
	GOTO       L__DisplayValueLED56
L__DisplayValueLED59:
	GOTO       L__DisplayValueLED54
;Huey 450.mbas,181 :: 		else                       'Display Count of Param P1
L__DisplayValueLED53:
;Huey 450.mbas,182 :: 		temp = P1 / 1000
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	MOVF       FARG_DisplayValueLED_P1+0, 0
	MOVWF      R0+0
	MOVF       FARG_DisplayValueLED_P1+1, 0
	MOVWF      R0+1
	CALL       _Div_16x16_U+0
	MOVF       R0+0, 0
	MOVWF      DisplayValueLED_Temp+0
	MOVF       R0+1, 0
	MOVWF      DisplayValueLED_Temp+1
;Huey 450.mbas,183 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED227:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED228
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED227
L__DisplayValueLED228:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,184 :: 		Delay_ms(3000)       'Pulse for start of 1000's indicator
	MOVLW      16
	MOVWF      R11+0
	MOVLW      57
	MOVWF      R12+0
	MOVLW      13
	MOVWF      R13+0
L__DisplayValueLED62:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED62
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED62
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED62
	NOP
	NOP
;Huey 450.mbas,185 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED229:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED230
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED229
L__DisplayValueLED230:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,186 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED63:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED63
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED63
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED63
	NOP
	NOP
;Huey 450.mbas,187 :: 		If temp > 0 then             'Count the 1000's
	MOVF       DisplayValueLED_Temp+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED231
	MOVF       DisplayValueLED_Temp+0, 0
	SUBLW      0
L__DisplayValueLED231:
	BTFSC      STATUS+0, 0
	GOTO       L__DisplayValueLED65
;Huey 450.mbas,189 :: 		for i = 1 to temp
	MOVLW      1
	MOVWF      _i+0
L__DisplayValueLED67:
	MOVLW      0
	SUBWF      DisplayValueLED_Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED232
	MOVF       _i+0, 0
	SUBWF      DisplayValueLED_Temp+0, 0
L__DisplayValueLED232:
	BTFSS      STATUS+0, 0
	GOTO       L__DisplayValueLED71
;Huey 450.mbas,190 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED233:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED234
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED233
L__DisplayValueLED234:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,191 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED72:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED72
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED72
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED72
	NOP
	NOP
;Huey 450.mbas,192 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED235:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED236
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED235
L__DisplayValueLED236:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,193 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED73:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED73
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED73
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED73
	NOP
	NOP
;Huey 450.mbas,194 :: 		Next i
	MOVLW      0
	XORWF      DisplayValueLED_Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED237
	MOVF       DisplayValueLED_Temp+0, 0
	XORWF      _i+0, 0
L__DisplayValueLED237:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED71
	INCF       _i+0, 1
	GOTO       L__DisplayValueLED67
L__DisplayValueLED71:
;Huey 450.mbas,195 :: 		Delay_ms(750)
	MOVLW      4
	MOVWF      R11+0
	MOVLW      207
	MOVWF      R12+0
	MOVLW      1
	MOVWF      R13+0
L__DisplayValueLED74:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED74
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED74
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED74
	NOP
	NOP
	GOTO       L__DisplayValueLED66
;Huey 450.mbas,196 :: 		Else                          'No 1000's
L__DisplayValueLED65:
;Huey 450.mbas,197 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED238:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED239
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED238
L__DisplayValueLED239:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,198 :: 		Delay_ms(75)
	MOVLW      98
	MOVWF      R12+0
	MOVLW      101
	MOVWF      R13+0
L__DisplayValueLED75:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED75
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED75
	NOP
	NOP
;Huey 450.mbas,199 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED240:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED241
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED240
L__DisplayValueLED241:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,200 :: 		Delay_ms(1000)
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__DisplayValueLED76:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED76
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED76
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED76
	NOP
	NOP
;Huey 450.mbas,201 :: 		End if
L__DisplayValueLED66:
;Huey 450.mbas,202 :: 		P1 = P1 - (temp * 1000)
	MOVF       DisplayValueLED_Temp+0, 0
	MOVWF      R0+0
	MOVF       DisplayValueLED_Temp+1, 0
	MOVWF      R0+1
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CALL       _Mul_16x16_U+0
	MOVF       R0+0, 0
	SUBWF      FARG_DisplayValueLED_P1+0, 0
	MOVWF      R0+0
	MOVF       R0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      FARG_DisplayValueLED_P1+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      FARG_DisplayValueLED_P1+0
	MOVF       R0+1, 0
	MOVWF      FARG_DisplayValueLED_P1+1
;Huey 450.mbas,203 :: 		temp = P1 / 100
	MOVLW      100
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Div_16x16_U+0
	MOVF       R0+0, 0
	MOVWF      DisplayValueLED_Temp+0
	MOVF       R0+1, 0
	MOVWF      DisplayValueLED_Temp+1
;Huey 450.mbas,204 :: 		SetBit(OutputPort1,OutputBit1)          'GP1 to go high.
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED242:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED243
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED242
L__DisplayValueLED243:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,205 :: 		Delay_ms(1000)       'Pulse for start of 100's indicator
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__DisplayValueLED77:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED77
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED77
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED77
	NOP
	NOP
;Huey 450.mbas,206 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED244:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED245
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED244
L__DisplayValueLED245:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,207 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED78:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED78
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED78
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED78
	NOP
	NOP
;Huey 450.mbas,208 :: 		If temp > 0 then             'Count the 100's
	MOVF       DisplayValueLED_Temp+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED246
	MOVF       DisplayValueLED_Temp+0, 0
	SUBLW      0
L__DisplayValueLED246:
	BTFSC      STATUS+0, 0
	GOTO       L__DisplayValueLED80
;Huey 450.mbas,210 :: 		for i = 1 to temp
	MOVLW      1
	MOVWF      _i+0
L__DisplayValueLED82:
	MOVLW      0
	SUBWF      DisplayValueLED_Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED247
	MOVF       _i+0, 0
	SUBWF      DisplayValueLED_Temp+0, 0
L__DisplayValueLED247:
	BTFSS      STATUS+0, 0
	GOTO       L__DisplayValueLED86
;Huey 450.mbas,211 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED248:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED249
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED248
L__DisplayValueLED249:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,212 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED87:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED87
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED87
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED87
	NOP
	NOP
;Huey 450.mbas,213 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED250:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED251
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED250
L__DisplayValueLED251:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,214 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED88:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED88
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED88
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED88
	NOP
	NOP
;Huey 450.mbas,215 :: 		Next i
	MOVLW      0
	XORWF      DisplayValueLED_Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED252
	MOVF       DisplayValueLED_Temp+0, 0
	XORWF      _i+0, 0
L__DisplayValueLED252:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED86
	INCF       _i+0, 1
	GOTO       L__DisplayValueLED82
L__DisplayValueLED86:
;Huey 450.mbas,216 :: 		Delay_ms(750)
	MOVLW      4
	MOVWF      R11+0
	MOVLW      207
	MOVWF      R12+0
	MOVLW      1
	MOVWF      R13+0
L__DisplayValueLED89:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED89
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED89
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED89
	NOP
	NOP
	GOTO       L__DisplayValueLED81
;Huey 450.mbas,217 :: 		Else                          'No 100's
L__DisplayValueLED80:
;Huey 450.mbas,218 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED253:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED254
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED253
L__DisplayValueLED254:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,219 :: 		Delay_ms(75)
	MOVLW      98
	MOVWF      R12+0
	MOVLW      101
	MOVWF      R13+0
L__DisplayValueLED90:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED90
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED90
	NOP
	NOP
;Huey 450.mbas,220 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED255:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED256
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED255
L__DisplayValueLED256:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,221 :: 		Delay_ms(1000)
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__DisplayValueLED91:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED91
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED91
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED91
	NOP
	NOP
;Huey 450.mbas,222 :: 		End if
L__DisplayValueLED81:
;Huey 450.mbas,223 :: 		P1 = P1 - (temp * 100)
	MOVF       DisplayValueLED_Temp+0, 0
	MOVWF      R0+0
	MOVF       DisplayValueLED_Temp+1, 0
	MOVWF      R0+1
	MOVLW      100
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Mul_16x16_U+0
	MOVF       R0+0, 0
	SUBWF      FARG_DisplayValueLED_P1+0, 0
	MOVWF      R0+0
	MOVF       R0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      FARG_DisplayValueLED_P1+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      FARG_DisplayValueLED_P1+0
	MOVF       R0+1, 0
	MOVWF      FARG_DisplayValueLED_P1+1
;Huey 450.mbas,224 :: 		temp = P1 / 10
	MOVLW      10
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Div_16x16_U+0
	MOVF       R0+0, 0
	MOVWF      DisplayValueLED_Temp+0
	MOVF       R0+1, 0
	MOVWF      DisplayValueLED_Temp+1
;Huey 450.mbas,225 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED257:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED258
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED257
L__DisplayValueLED258:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,226 :: 		Delay_ms(1000)       'Pulse for start of 10's indicator
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__DisplayValueLED92:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED92
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED92
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED92
	NOP
	NOP
;Huey 450.mbas,227 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED259:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED260
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED259
L__DisplayValueLED260:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,228 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED93:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED93
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED93
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED93
	NOP
	NOP
;Huey 450.mbas,229 :: 		If temp > 0 then             'Count the 10's
	MOVF       DisplayValueLED_Temp+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED261
	MOVF       DisplayValueLED_Temp+0, 0
	SUBLW      0
L__DisplayValueLED261:
	BTFSC      STATUS+0, 0
	GOTO       L__DisplayValueLED95
;Huey 450.mbas,231 :: 		for i = 1 to temp
	MOVLW      1
	MOVWF      _i+0
L__DisplayValueLED97:
	MOVLW      0
	SUBWF      DisplayValueLED_Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED262
	MOVF       _i+0, 0
	SUBWF      DisplayValueLED_Temp+0, 0
L__DisplayValueLED262:
	BTFSS      STATUS+0, 0
	GOTO       L__DisplayValueLED101
;Huey 450.mbas,232 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED263:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED264
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED263
L__DisplayValueLED264:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,233 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED102:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED102
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED102
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED102
	NOP
	NOP
;Huey 450.mbas,234 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED265:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED266
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED265
L__DisplayValueLED266:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,235 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED103:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED103
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED103
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED103
	NOP
	NOP
;Huey 450.mbas,236 :: 		Next i
	MOVLW      0
	XORWF      DisplayValueLED_Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED267
	MOVF       DisplayValueLED_Temp+0, 0
	XORWF      _i+0, 0
L__DisplayValueLED267:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED101
	INCF       _i+0, 1
	GOTO       L__DisplayValueLED97
L__DisplayValueLED101:
;Huey 450.mbas,237 :: 		Delay_ms(750)
	MOVLW      4
	MOVWF      R11+0
	MOVLW      207
	MOVWF      R12+0
	MOVLW      1
	MOVWF      R13+0
L__DisplayValueLED104:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED104
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED104
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED104
	NOP
	NOP
	GOTO       L__DisplayValueLED96
;Huey 450.mbas,238 :: 		Else                          'No 10's
L__DisplayValueLED95:
;Huey 450.mbas,239 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED268:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED269
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED268
L__DisplayValueLED269:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,240 :: 		Delay_ms(75)
	MOVLW      98
	MOVWF      R12+0
	MOVLW      101
	MOVWF      R13+0
L__DisplayValueLED105:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED105
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED105
	NOP
	NOP
;Huey 450.mbas,241 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED270:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED271
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED270
L__DisplayValueLED271:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,242 :: 		Delay_ms(1000)
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__DisplayValueLED106:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED106
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED106
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED106
	NOP
	NOP
;Huey 450.mbas,243 :: 		End if
L__DisplayValueLED96:
;Huey 450.mbas,244 :: 		P1 = P1 - (temp * 10)
	MOVF       DisplayValueLED_Temp+0, 0
	MOVWF      R0+0
	MOVF       DisplayValueLED_Temp+1, 0
	MOVWF      R0+1
	MOVLW      10
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Mul_16x16_U+0
	MOVF       R0+0, 0
	SUBWF      FARG_DisplayValueLED_P1+0, 0
	MOVWF      R0+0
	MOVF       R0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      FARG_DisplayValueLED_P1+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      FARG_DisplayValueLED_P1+0
	MOVF       R0+1, 0
	MOVWF      FARG_DisplayValueLED_P1+1
;Huey 450.mbas,245 :: 		temp = P1
	MOVF       R0+0, 0
	MOVWF      DisplayValueLED_Temp+0
	MOVF       R0+1, 0
	MOVWF      DisplayValueLED_Temp+1
;Huey 450.mbas,246 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED272:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED273
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED272
L__DisplayValueLED273:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,247 :: 		Delay_ms(1000)       'Pulse for start of 1's indicator
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__DisplayValueLED107:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED107
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED107
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED107
	NOP
	NOP
;Huey 450.mbas,248 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED274:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED275
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED274
L__DisplayValueLED275:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,249 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED108:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED108
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED108
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED108
	NOP
	NOP
;Huey 450.mbas,250 :: 		If temp > 0 then             'Count the 1's
	MOVF       DisplayValueLED_Temp+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED276
	MOVF       DisplayValueLED_Temp+0, 0
	SUBLW      0
L__DisplayValueLED276:
	BTFSC      STATUS+0, 0
	GOTO       L__DisplayValueLED110
;Huey 450.mbas,252 :: 		for i = 1 to temp
	MOVLW      1
	MOVWF      _i+0
L__DisplayValueLED112:
	MOVLW      0
	SUBWF      DisplayValueLED_Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED277
	MOVF       _i+0, 0
	SUBWF      DisplayValueLED_Temp+0, 0
L__DisplayValueLED277:
	BTFSS      STATUS+0, 0
	GOTO       L__DisplayValueLED116
;Huey 450.mbas,253 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED278:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED279
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED278
L__DisplayValueLED279:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,254 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED117:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED117
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED117
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED117
	NOP
	NOP
;Huey 450.mbas,255 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED280:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED281
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED280
L__DisplayValueLED281:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,256 :: 		Delay_ms(250)
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L__DisplayValueLED118:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED118
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED118
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED118
	NOP
	NOP
;Huey 450.mbas,257 :: 		Next i
	MOVLW      0
	XORWF      DisplayValueLED_Temp+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__DisplayValueLED282
	MOVF       DisplayValueLED_Temp+0, 0
	XORWF      _i+0, 0
L__DisplayValueLED282:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED116
	INCF       _i+0, 1
	GOTO       L__DisplayValueLED112
L__DisplayValueLED116:
;Huey 450.mbas,258 :: 		Delay_ms(750)
	MOVLW      4
	MOVWF      R11+0
	MOVLW      207
	MOVWF      R12+0
	MOVLW      1
	MOVWF      R13+0
L__DisplayValueLED119:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED119
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED119
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED119
	NOP
	NOP
	GOTO       L__DisplayValueLED111
;Huey 450.mbas,259 :: 		Else                          'No 1's
L__DisplayValueLED110:
;Huey 450.mbas,260 :: 		SetBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED283:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED284
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED283
L__DisplayValueLED284:
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	IORWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,261 :: 		Delay_ms(75)
	MOVLW      98
	MOVWF      R12+0
	MOVLW      101
	MOVWF      R13+0
L__DisplayValueLED120:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED120
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED120
	NOP
	NOP
;Huey 450.mbas,262 :: 		ClearBit(OutputPort1,OutputBit1)
	MOVF       FARG_DisplayValueLED_OutputBit1+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__DisplayValueLED285:
	BTFSC      STATUS+0, 2
	GOTO       L__DisplayValueLED286
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__DisplayValueLED285
L__DisplayValueLED286:
	COMF       R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	ANDWF      R0+0, 1
	MOVF       FARG_DisplayValueLED_OutputPort1+0, 0
	MOVWF      FSR
	MOVF       R0+0, 0
	MOVWF      INDF+0
;Huey 450.mbas,263 :: 		Delay_ms(1000)
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__DisplayValueLED121:
	DECFSZ     R13+0, 1
	GOTO       L__DisplayValueLED121
	DECFSZ     R12+0, 1
	GOTO       L__DisplayValueLED121
	DECFSZ     R11+0, 1
	GOTO       L__DisplayValueLED121
	NOP
	NOP
;Huey 450.mbas,264 :: 		End if
L__DisplayValueLED111:
;Huey 450.mbas,265 :: 		End if
L__DisplayValueLED54:
;Huey 450.mbas,266 :: 		End Sub
L_end_DisplayValueLED:
	RETURN
; end of _DisplayValueLED

_LEDS:

;Huey 450.mbas,269 :: 		sub procedure LEDS(Dim P1 as Byte)
;Huey 450.mbas,274 :: 		adData = ADC_Get_Sample(2)
	MOVLW      2
	MOVWF      FARG_ADC_Get_Sample_channel+0
	CALL       _ADC_Get_Sample+0
	MOVF       R0+0, 0
	MOVWF      _adData+0
	MOVF       R0+1, 0
	MOVWF      _adData+1
;Huey 450.mbas,278 :: 		adData = adData * 0.5
	CALL       _Word2Double+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      0
	MOVWF      R4+2
	MOVLW      126
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	CALL       _Double2Word+0
	MOVF       R0+0, 0
	MOVWF      _adData+0
	MOVF       R0+1, 0
	MOVWF      _adData+1
;Huey 450.mbas,280 :: 		adData = adData - 15
	MOVLW      15
	SUBWF      R0+0, 0
	MOVWF      R2+0
	MOVLW      0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      R0+1, 0
	MOVWF      R2+1
	MOVF       R2+0, 0
	MOVWF      _adData+0
	MOVF       R2+1, 0
	MOVWF      _adData+1
;Huey 450.mbas,285 :: 		If adData < 65000 then
	MOVLW      253
	SUBWF      R2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__LEDS288
	MOVLW      232
	SUBWF      R2+0, 0
L__LEDS288:
	BTFSC      STATUS+0, 0
	GOTO       L__LEDS124
;Huey 450.mbas,286 :: 		MainBatteryDetected = 1
	BSF        _MainBatteryDetected+0, BitPos(_MainBatteryDetected+0)
L__LEDS124:
;Huey 450.mbas,291 :: 		if adData < LowVoltageRef then
	MOVLW      1
	SUBWF      _adData+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__LEDS289
	MOVLW      84
	SUBWF      _adData+0, 0
L__LEDS289:
	BTFSC      STATUS+0, 0
	GOTO       L__LEDS127
;Huey 450.mbas,295 :: 		LowVoltageCount = LowVoltageCount + 1
	INCF       _LowVoltageCount+0, 1
;Huey 450.mbas,296 :: 		If LowVoltageCount > 4 then       '12v ref has been low for the
	MOVF       _LowVoltageCount+0, 0
	SUBLW      4
	BTFSC      STATUS+0, 0
	GOTO       L__LEDS130
;Huey 450.mbas,297 :: 		LowVoltageHold = 1             'last 5 LED changes.
	BSF        _LowVoltageHold+0, BitPos(_LowVoltageHold+0)
;Huey 450.mbas,298 :: 		LowVoltageCount = 0            'Tell the main prog to stop the
	CLRF       _LowVoltageCount+0
L__LEDS130:
;Huey 450.mbas,299 :: 		End if                            'LEDs flashing to warn the pilot.
	GOTO       L__LEDS128
;Huey 450.mbas,300 :: 		Else
L__LEDS127:
;Huey 450.mbas,301 :: 		LowVoltageCount = 0            '12v reference is good, reset counter.
	CLRF       _LowVoltageCount+0
;Huey 450.mbas,302 :: 		If LowVoltageDisplayed = 1 then    'If the warning has been display
	BTFSS      _LowVoltageDisplayed+0, BitPos(_LowVoltageDisplayed+0)
	GOTO       L__LEDS133
;Huey 450.mbas,303 :: 		LowVoltageHold = 0               'then switch it off if the vlotage
	BCF        _LowVoltageHold+0, BitPos(_LowVoltageHold+0)
;Huey 450.mbas,304 :: 		LowVoltageDisplayed = 0          'is OK again.
	BCF        _LowVoltageDisplayed+0, BitPos(_LowVoltageDisplayed+0)
L__LEDS133:
;Huey 450.mbas,306 :: 		End If
L__LEDS128:
;Huey 450.mbas,308 :: 		if adData < LowVoltPowerUpRef then   'Check the initial power up voltage
	MOVLW      1
	SUBWF      _adData+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__LEDS290
	MOVLW      189
	SUBWF      _adData+0, 0
L__LEDS290:
	BTFSC      STATUS+0, 0
	GOTO       L__LEDS136
;Huey 450.mbas,309 :: 		LowVoltPowerUp = 1               'Battery not fully changed
	BSF        _LowVoltPowerUp+0, BitPos(_LowVoltPowerUp+0)
L__LEDS136:
;Huey 450.mbas,312 :: 		if adData < CriticalVoltPowerUpRef then 'Check the init power up voltage
	MOVLW      1
	SUBWF      _adData+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__LEDS291
	MOVLW      174
	SUBWF      _adData+0, 0
L__LEDS291:
	BTFSC      STATUS+0, 0
	GOTO       L__LEDS139
;Huey 450.mbas,313 :: 		CriticalVoltPowerUp = 1              'Battery at critical discharge
	BSF        _CriticalVoltPowerUp+0, BitPos(_CriticalVoltPowerUp+0)
L__LEDS139:
;Huey 450.mbas,317 :: 		PulseCounter(GPIO,3)
	MOVLW      GPIO+0
	MOVWF      FARG_PulseCounter_Port+0
	MOVLW      3
	MOVWF      FARG_PulseCounter_PortBit+0
	CALL       _PulseCounter+0
;Huey 450.mbas,318 :: 		if RxSwitch = 0 then
	BTFSC      _RxSwitch+0, BitPos(_RxSwitch+0)
	GOTO       L__LEDS142
;Huey 450.mbas,319 :: 		GPIO.B0 = 0
	BCF        GPIO+0, 0
	GOTO       L__LEDS143
;Huey 450.mbas,320 :: 		else
L__LEDS142:
;Huey 450.mbas,321 :: 		GPIO.B0 = 1
	BSF        GPIO+0, 0
;Huey 450.mbas,322 :: 		End if
L__LEDS143:
;Huey 450.mbas,328 :: 		if (P1 >> 1) AND 1 = 1 then           'Repeat for all posible Bits
	MOVF       FARG_LEDS_P1+0, 0
	MOVWF      R0+0
	RRF        R0+0, 1
	BCF        R0+0, 7
	MOVLW      1
	ANDWF      R0+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__LEDS145
;Huey 450.mbas,329 :: 		GPIO.B1 = 1
	BSF        GPIO+0, 1
	GOTO       L__LEDS146
;Huey 450.mbas,330 :: 		else
L__LEDS145:
;Huey 450.mbas,331 :: 		GPIO.B1 = 0
	BCF        GPIO+0, 1
;Huey 450.mbas,332 :: 		end if
L__LEDS146:
;Huey 450.mbas,334 :: 		if (P1 >> 4) AND 1 = 1 then
	MOVF       FARG_LEDS_P1+0, 0
	MOVWF      R0+0
	RRF        R0+0, 1
	BCF        R0+0, 7
	RRF        R0+0, 1
	BCF        R0+0, 7
	RRF        R0+0, 1
	BCF        R0+0, 7
	RRF        R0+0, 1
	BCF        R0+0, 7
	MOVLW      1
	ANDWF      R0+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__LEDS148
;Huey 450.mbas,335 :: 		GPIO.B4 = 1
	BSF        GPIO+0, 4
	GOTO       L__LEDS149
;Huey 450.mbas,336 :: 		else
L__LEDS148:
;Huey 450.mbas,337 :: 		GPIO.B4 = 0
	BCF        GPIO+0, 4
;Huey 450.mbas,338 :: 		end if
L__LEDS149:
;Huey 450.mbas,340 :: 		Delay_ms(75)
	MOVLW      98
	MOVWF      R12+0
	MOVLW      101
	MOVWF      R13+0
L__LEDS150:
	DECFSZ     R13+0, 1
	GOTO       L__LEDS150
	DECFSZ     R12+0, 1
	GOTO       L__LEDS150
	NOP
	NOP
;Huey 450.mbas,341 :: 		End Sub
L_end_LEDS:
	RETURN
; end of _LEDS

_main:

;Huey 450.mbas,344 :: 		main:
;Huey 450.mbas,346 :: 		OPTION_REG = %10000111     'GPIO pull ups are disabled and
	MOVLW      135
	MOVWF      OPTION_REG+0
;Huey 450.mbas,351 :: 		Gain = SetGyroGain         '0 to 100% based on Symbol setting at the top
	MOVLW      80
	MOVWF      _Gain+0
;Huey 450.mbas,356 :: 		Gain = 0
L__main153:
;Huey 450.mbas,358 :: 		If Gain > 100 then         'Gain should never be > 100
	MOVF       _Gain+0, 0
	SUBLW      100
	BTFSC      STATUS+0, 0
	GOTO       L__main156
;Huey 450.mbas,359 :: 		Gain = 100
	MOVLW      100
	MOVWF      _Gain+0
L__main156:
;Huey 450.mbas,367 :: 		Smoother = Gain / 25
	MOVLW      25
	MOVWF      R4+0
	MOVF       _Gain+0, 0
	MOVWF      R0+0
	CALL       _Div_8x8_U+0
	MOVF       R0+0, 0
	MOVWF      _Smoother+0
;Huey 450.mbas,368 :: 		Delay = (((Gain * 100) / 25) - (Smoother * 100)) / 9.5
	MOVF       _Gain+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVLW      100
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Mul_16x16_U+0
	MOVLW      25
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Div_16x16_U+0
	MOVF       R0+0, 0
	MOVWF      FLOC__main+0
	MOVF       R0+1, 0
	MOVWF      FLOC__main+1
	MOVF       _Smoother+0, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVLW      100
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Mul_16x16_U+0
	MOVF       R0+0, 0
	SUBWF      FLOC__main+0, 0
	MOVWF      R0+0
	MOVF       R0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBWF      FLOC__main+1, 0
	MOVWF      R0+1
	CALL       _Word2Double+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      24
	MOVWF      R4+2
	MOVLW      130
	MOVWF      R4+3
	CALL       _Div_32x32_FP+0
	CALL       _Double2Int+0
	MOVF       R0+0, 0
	MOVWF      _Delay+0
	MOVF       R0+1, 0
	MOVWF      _Delay+1
;Huey 450.mbas,370 :: 		ANSEL  = %01010100          'Set AN2 as analogue and others digital
	MOVLW      84
	MOVWF      ANSEL+0
;Huey 450.mbas,373 :: 		TRISIO = %00000100          'Set GP2 as Input, others as Outputs
	MOVLW      4
	MOVWF      TRISIO+0
;Huey 450.mbas,374 :: 		CMCON0 = %00000111          'Configure CIN pins as I/O & COUT pin as I/O
	MOVLW      7
	MOVWF      CMCON0+0
;Huey 450.mbas,376 :: 		TMR0 = 178                  'Start the timer, 19.968 ms before each call.
	MOVLW      178
	MOVWF      TMR0+0
;Huey 450.mbas,380 :: 		INTCON = %10100000          'Reset the Flags and start the interrupt service.
	MOVLW      160
	MOVWF      INTCON+0
;Huey 450.mbas,382 :: 		LowVoltPowerUp = 0          'Reset all voltage warnings for the first pass.
	BCF        _LowVoltPowerUp+0, BitPos(_LowVoltPowerUp+0)
;Huey 450.mbas,383 :: 		CriticalVoltPowerUp = 0
	BCF        _CriticalVoltPowerUp+0, BitPos(_CriticalVoltPowerUp+0)
;Huey 450.mbas,384 :: 		LowVoltageDisplayed = 0
	BCF        _LowVoltageDisplayed+0, BitPos(_LowVoltageDisplayed+0)
;Huey 450.mbas,390 :: 		ADC_init()
	CALL       _ADC_Init+0
;Huey 450.mbas,394 :: 		Delay_ms(1000)
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L__main158:
	DECFSZ     R13+0, 1
	GOTO       L__main158
	DECFSZ     R12+0, 1
	GOTO       L__main158
	DECFSZ     R11+0, 1
	GOTO       L__main158
	NOP
	NOP
;Huey 450.mbas,395 :: 		MainBatteryDetected = 0
	BCF        _MainBatteryDetected+0, BitPos(_MainBatteryDetected+0)
;Huey 450.mbas,396 :: 		While MainBatteryDetected = 0
L__main160:
	BTFSC      _MainBatteryDetected+0, BitPos(_MainBatteryDetected+0)
	GOTO       L__main161
;Huey 450.mbas,397 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,398 :: 		Wend
	GOTO       L__main160
L__main161:
;Huey 450.mbas,404 :: 		LEDS(%00010011)
	MOVLW      19
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,405 :: 		Delay_ms(3000)
	MOVLW      16
	MOVWF      R11+0
	MOVLW      57
	MOVWF      R12+0
	MOVLW      13
	MOVWF      R13+0
L__main164:
	DECFSZ     R13+0, 1
	GOTO       L__main164
	DECFSZ     R12+0, 1
	GOTO       L__main164
	DECFSZ     R11+0, 1
	GOTO       L__main164
	NOP
	NOP
;Huey 450.mbas,406 :: 		LEDS(%00000000)             'Enter into the loop with the LEDs off
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,407 :: 		For i = 1 to ProgramVersion 'Flash the LEDs once for each version.
	MOVLW      1
	MOVWF      _i+0
L__main166:
;Huey 450.mbas,408 :: 		Delay_ms(75)
	MOVLW      98
	MOVWF      R12+0
	MOVLW      101
	MOVWF      R13+0
L__main170:
	DECFSZ     R13+0, 1
	GOTO       L__main170
	DECFSZ     R12+0, 1
	GOTO       L__main170
	NOP
	NOP
;Huey 450.mbas,409 :: 		LEDS(%00010011)
	MOVLW      19
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,410 :: 		Delay_ms(75)
	MOVLW      98
	MOVWF      R12+0
	MOVLW      101
	MOVWF      R13+0
L__main171:
	DECFSZ     R13+0, 1
	GOTO       L__main171
	DECFSZ     R12+0, 1
	GOTO       L__main171
	NOP
	NOP
;Huey 450.mbas,411 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,412 :: 		Next i
	MOVF       _i+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L__main169
	INCF       _i+0, 1
	GOTO       L__main166
L__main169:
;Huey 450.mbas,413 :: 		Delay_ms(500)
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L__main172:
	DECFSZ     R13+0, 1
	GOTO       L__main172
	DECFSZ     R12+0, 1
	GOTO       L__main172
	DECFSZ     R11+0, 1
	GOTO       L__main172
	NOP
	NOP
;Huey 450.mbas,419 :: 		if CriticalVoltPowerUp = 1 then
	BTFSS      _CriticalVoltPowerUp+0, BitPos(_CriticalVoltPowerUp+0)
	GOTO       L__main174
;Huey 450.mbas,420 :: 		While True                   'Pulse the LEDS fast forever to warn
L__main177:
;Huey 450.mbas,421 :: 		LEDS(%00010011)          'the pilot.
	MOVLW      19
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,422 :: 		Delay_ms(10)
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L__main181:
	DECFSZ     R13+0, 1
	GOTO       L__main181
	DECFSZ     R12+0, 1
	GOTO       L__main181
	NOP
	NOP
;Huey 450.mbas,423 :: 		LEDS(%00000000)          'The interupt service will still hold the
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,424 :: 		Delay_ms(10)             'tail gyro if the pilot ignores the warning.
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L__main182:
	DECFSZ     R13+0, 1
	GOTO       L__main182
	DECFSZ     R12+0, 1
	GOTO       L__main182
	NOP
	NOP
;Huey 450.mbas,425 :: 		Wend
	GOTO       L__main177
L__main174:
;Huey 450.mbas,431 :: 		if LowVoltPowerUp = 1 then
	BTFSS      _LowVoltPowerUp+0, BitPos(_LowVoltPowerUp+0)
	GOTO       L__main184
;Huey 450.mbas,432 :: 		For i = 1 to 30
	MOVLW      1
	MOVWF      _i+0
L__main187:
;Huey 450.mbas,433 :: 		LEDS(%00010011)
	MOVLW      19
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,434 :: 		Delay_ms(500)
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L__main191:
	DECFSZ     R13+0, 1
	GOTO       L__main191
	DECFSZ     R12+0, 1
	GOTO       L__main191
	DECFSZ     R11+0, 1
	GOTO       L__main191
	NOP
	NOP
;Huey 450.mbas,435 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,436 :: 		Delay_ms(500)
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L__main192:
	DECFSZ     R13+0, 1
	GOTO       L__main192
	DECFSZ     R12+0, 1
	GOTO       L__main192
	DECFSZ     R11+0, 1
	GOTO       L__main192
	NOP
	NOP
;Huey 450.mbas,437 :: 		Next i
	MOVF       _i+0, 0
	XORLW      30
	BTFSC      STATUS+0, 2
	GOTO       L__main190
	INCF       _i+0, 1
	GOTO       L__main187
L__main190:
L__main184:
;Huey 450.mbas,441 :: 		LowVoltageHold = 0
	BCF        _LowVoltageHold+0, BitPos(_LowVoltageHold+0)
;Huey 450.mbas,442 :: 		LowVoltageCount = 0
	CLRF       _LowVoltageCount+0
;Huey 450.mbas,443 :: 		RxSwitch = 0
	BCF        _RxSwitch+0, BitPos(_RxSwitch+0)
;Huey 450.mbas,446 :: 		While True
L__main194:
;Huey 450.mbas,452 :: 		If LowVoltageHold = 1 then
	BTFSS      _LowVoltageHold+0, BitPos(_LowVoltageHold+0)
	GOTO       L__main199
;Huey 450.mbas,454 :: 		LEDS(%00010010)
	MOVLW      18
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,457 :: 		Delay_ms(10000)      '10 Seconds
	MOVLW      51
	MOVWF      R11+0
	MOVLW      187
	MOVWF      R12+0
	MOVLW      223
	MOVWF      R13+0
L__main201:
	DECFSZ     R13+0, 1
	GOTO       L__main201
	DECFSZ     R12+0, 1
	GOTO       L__main201
	DECFSZ     R11+0, 1
	GOTO       L__main201
	NOP
	NOP
;Huey 450.mbas,458 :: 		LEDS(%00010010)      'Call LEDS again, only to recheck the
	MOVLW      18
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,461 :: 		LowVoltageDisplayed = 1
	BSF        _LowVoltageDisplayed+0, BitPos(_LowVoltageDisplayed+0)
	GOTO       L__main200
;Huey 450.mbas,462 :: 		Else
L__main199:
;Huey 450.mbas,473 :: 		For i=0 to 2
	CLRF       _i+0
L__main203:
;Huey 450.mbas,482 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,483 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,484 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,485 :: 		LEDS(%00010000)
	MOVLW      16
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,486 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,487 :: 		LEDS(%00010000)
	MOVLW      16
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,488 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,489 :: 		LEDS(%00010000)
	MOVLW      16
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,490 :: 		Next i
	MOVF       _i+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L__main206
	INCF       _i+0, 1
	GOTO       L__main203
L__main206:
;Huey 450.mbas,491 :: 		If Smoother > 1 then      'Gyro in Head Held Mode
	MOVF       _Smoother+0, 0
	SUBLW      1
	BTFSC      STATUS+0, 0
	GOTO       L__main208
;Huey 450.mbas,500 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,501 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,502 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,503 :: 		LEDS(%00010010)
	MOVLW      18
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,504 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,505 :: 		LEDS(%00010000)
	MOVLW      16
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,506 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,507 :: 		LEDS(%00010000)
	MOVLW      16
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
	GOTO       L__main209
;Huey 450.mbas,508 :: 		Else                      'Gyro in Rate Mode so keep flashing the becon
L__main208:
;Huey 450.mbas,517 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,518 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,519 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,520 :: 		LEDS(%00010000)
	MOVLW      16
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,521 :: 		LEDS(%00000010)
	MOVLW      2
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,522 :: 		LEDS(%00010000)
	MOVLW      16
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,523 :: 		LEDS(%00000000)
	CLRF       FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,524 :: 		LEDS(%00010000)
	MOVLW      16
	MOVWF      FARG_LEDS_P1+0
	CALL       _LEDS+0
;Huey 450.mbas,525 :: 		End if
L__main209:
;Huey 450.mbas,526 :: 		end if
L__main200:
;Huey 450.mbas,527 :: 		Wend
	GOTO       L__main194
L_end_main:
	GOTO       $+0
; end of _main
