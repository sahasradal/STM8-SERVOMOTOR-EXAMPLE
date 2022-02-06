# STM8-SERVOMOTOR-EXAMPLE
STM8 SERVOMOTOR EXAMPLE in ASSEMBLY LANGUAGE
The stack initialisation and the interrupt vector tables are created by the ST-VISUAL DEVELOPER on creating a new project. The STM8SF103.inc & STM8SF103.asm files should be manually included from the C:\Program Files (x86)\STMicroelectronics\st_toolset\asm\include to the project source folder where the main.s file resides. The program can be burned to the chip using stlink chinese clone with ST VISUAL PROGRAMMER software from ST electronics. 
The code is using timer2 chanel2 PD3 to output PWM signals to the servo motor
The program enables the timer2 with PWM mode and the output comes on PD3 which is connected to servo motor PWM wire.
The 0degree position is maintained when 0.5ms(500us) is sent to the motor
The shaft is positioned at 180degress when 2.4ms PWM signal is sent to servomotor.
The frequency of the signal is 50Hz
The program alternates between 0 degree and 180 degree by sending the appopriate timer compare match values from the look up table stored in the array.
Multiple values between the 0 and 180 degrees can be calculated and stored in the array to get respective positions
