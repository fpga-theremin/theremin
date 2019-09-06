module theremin_pwm
#(
    parameter PWM_COUNTER_BITS = 16
)
(
    // input clock
    input logic CLK,
    // reset, active 1
    input logic RESET,

    // color of LED0 (4 bits per R, G, B)    
    input logic [11:0] RGB_LED_COLOR0,
    // color of LED0 (4 bits per R, G, B)    
    input logic [11:0] RGB_LED_COLOR1,

    // color led0 control output {r,g,b}
    output logic [2:0] LED0_PWM,
    // color led1 control output {r,g,b}
    output logic [2:0] LED1_PWM,
    
    
    // backlight brightness setting, 0=dark, 255=light
    input logic [7:0] BACKLIGHT_BRIGHTNESS,
    // backlight PWM control output
    output logic BACKLIGHT_PWM
);

logic pwm;
logic [2:0] ledpwm0;
logic [2:0] ledpwm1;

logic [PWM_COUNTER_BITS-1:0] pwm_counter;
localparam BACKLIGHT_PWM_LOW_BITS = PWM_COUNTER_BITS - 8;
localparam RGB_LED_PWM_LOW_BITS = PWM_COUNTER_BITS - 5;

logic [BACKLIGHT_PWM_LOW_BITS-1:0] backlight_low_bits;
always_comb backlight_low_bits <= pwm_counter[BACKLIGHT_PWM_LOW_BITS-1:0];
logic [7:0] backlight_high_bits;
always_comb backlight_high_bits <= pwm_counter[PWM_COUNTER_BITS-1:BACKLIGHT_PWM_LOW_BITS];

logic [RGB_LED_PWM_LOW_BITS-1:0] rgb_led_low_bits;
always_comb rgb_led_low_bits <= pwm_counter[RGB_LED_PWM_LOW_BITS-1:0];
logic [4:0] rgb_led_high_bits;
always_comb rgb_led_high_bits <= pwm_counter[PWM_COUNTER_BITS-1:RGB_LED_PWM_LOW_BITS];

always @(posedge CLK) begin
    if (RESET) begin
        pwm_counter <= 'b0;
        pwm <= 'b0;
        ledpwm0 <= 'b0;
        ledpwm1 <= 'b0;
    end else begin
        pwm_counter <= pwm_counter + 1;
        if (&backlight_low_bits) begin
            if (backlight_high_bits == 8'hFF) begin
                pwm <= 1'b1;
            end else begin
                if (backlight_high_bits == BACKLIGHT_BRIGHTNESS)
                    pwm <= 1'b0;
            end
        end
        if (&rgb_led_low_bits) begin
            // led0
            if (rgb_led_high_bits == 5'b00000) begin
                ledpwm0[2] <= 3'b1;
            end if (rgb_led_high_bits == {1'b0, RGB_LED_COLOR0[11:8]}) begin
                ledpwm0[2] <= 3'b0;
            end
            if (rgb_led_high_bits == 5'b00000) begin
                ledpwm0[1] <= 3'b1;
            end if (rgb_led_high_bits == {1'b0, RGB_LED_COLOR0[7:4]}) begin
                ledpwm0[1] <= 3'b0;
            end
            if (rgb_led_high_bits == 5'b00000) begin
                ledpwm0[0] <= 3'b1;
            end if (rgb_led_high_bits == {1'b0, RGB_LED_COLOR0[3:0]}) begin
                ledpwm0[0] <= 3'b0;
            end
            // led1
            if (rgb_led_high_bits == 5'b00000) begin
                ledpwm1[2] <= 3'b1;
            end if (rgb_led_high_bits == {1'b0, RGB_LED_COLOR1[11:8]}) begin
                ledpwm1[2] <= 3'b0;
            end
            if (rgb_led_high_bits == 5'b00000) begin
                ledpwm1[1] <= 3'b1;
            end if (rgb_led_high_bits == {1'b0, RGB_LED_COLOR1[7:4]}) begin
                ledpwm1[1] <= 3'b0;
            end
            if (rgb_led_high_bits == 5'b00000) begin
                ledpwm1[0] <= 3'b1;
            end if (rgb_led_high_bits == {1'b0, RGB_LED_COLOR1[3:0]}) begin
                ledpwm1[0] <= 3'b0;
            end
        end
    end
end
always_comb BACKLIGHT_PWM <= pwm;
always_comb LED0_PWM <= ledpwm0;
always_comb LED1_PWM <= ledpwm1;


endmodule

