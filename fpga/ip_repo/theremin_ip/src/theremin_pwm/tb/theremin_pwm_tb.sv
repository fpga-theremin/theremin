`timescale 1ns / 1ps
module theremin_pwm_tb();

logic RESET;
logic CLK;

// backlight brightness setting, 0=dark, 255=light
logic [7:0] BACKLIGHT_BRIGHTNESS;
// backlight PWM control output
logic BACKLIGHT_PWM;

// color of LED0 (4 bits per R, G, B)    
logic [11:0] RGB_LED_COLOR0;
// color of LED0 (4 bits per R, G, B)    
logic [11:0] RGB_LED_COLOR1;

// color led0 control output {r,g,b}
logic [2:0] LED0_PWM;
// color led1 control output {r,g,b}
logic [2:0] LED1_PWM;


theremin_pwm theremin_pwm_inst(
 .*
);


initial begin
    RGB_LED_COLOR0 = 12'hf40;   RGB_LED_COLOR1 = 12'hc82;
    BACKLIGHT_BRIGHTNESS = 0;
    #15 RESET = 1;
    #215 RESET = 0;
    #10ms BACKLIGHT_BRIGHTNESS = 0;     RGB_LED_COLOR0 = 12'hfc4;   RGB_LED_COLOR1 = 12'h123;
    #10ms BACKLIGHT_BRIGHTNESS = 255;   RGB_LED_COLOR0 = 12'h842;   RGB_LED_COLOR1 = 12'hfea;
    #10ms BACKLIGHT_BRIGHTNESS = 8;     RGB_LED_COLOR0 = 12'hfc4;   RGB_LED_COLOR1 = 12'h123;
    #10ms BACKLIGHT_BRIGHTNESS = 255-8; RGB_LED_COLOR0 = 12'h234;   RGB_LED_COLOR1 = 12'h567;
    #10ms BACKLIGHT_BRIGHTNESS = 64;    RGB_LED_COLOR0 = 12'hfec;   RGB_LED_COLOR1 = 12'hdba;
    #10ms BACKLIGHT_BRIGHTNESS = 192;   RGB_LED_COLOR0 = 12'h111;   RGB_LED_COLOR1 = 12'h222;
    #10ms BACKLIGHT_BRIGHTNESS = 128;   RGB_LED_COLOR0 = 12'hfff;   RGB_LED_COLOR1 = 12'heee;
end

//37.5 MHz
always begin
    #13.3333 CLK = 1;
    #13.3333 CLK = 0; 
end


endmodule
