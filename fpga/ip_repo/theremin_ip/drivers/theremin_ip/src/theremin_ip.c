#include "theremin_ip.h"


#include <xil_types.h>
#include <xstatus.h>
#include <xscugic.h>
#include <sleep.h>
#include <xil_io.h>
#include <xil_misc_psreset_api.h>
#include <xil_cache.h>

pixel_t * SCREEN = nullptr;
void thereminLCD_setFramebufferAddress(pixel_t * buf) {
	thereminIO_writeReg(THEREMIN_WR_REG_LCD_FRAMEBUFFER_ADDR, (uint32_t)buf);
	SCREEN = buf;
}
pixel_t * thereminLCD_getFramebufferAddress() {
	return SCREEN;
}

// Read Theremin IP register value
uint32_t thereminIO_readReg(uint32_t offset) {
	return Xil_In32(XPAR_THEREMIN_IO_IP_0_BASEADDR + offset);
}
// Write Theremin IP register value
void thereminIO_writeReg(uint32_t offset, uint32_t value) {
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + offset, value);
}

uint32_t pwm_reg_value = 0x000000ff;

void thereminIO_setBacklightBrightness(uint32_t brightness) {
	pwm_reg_value = (pwm_reg_value & 0xffffff00) | (brightness & 0xff);
	thereminIO_writeReg(THEREMIN_WR_REG_PWM,
			pwm_reg_value);
}

uint32_t thereminIO_getBacklightBrightness() {
	return pwm_reg_value & 0xff;
}

void thereminIO_setLed0Color(uint32_t color) {
	uint32_t packedColor =
			((color >> 12)&0xf00)
		  | ((color >> 8)&0x0f0)
		  | ((color >> 4)&0x00f);
	pwm_reg_value = (pwm_reg_value & 0xfff000ff) | (packedColor << 8);
	thereminIO_writeReg(THEREMIN_WR_REG_PWM,
			pwm_reg_value);
}

void thereminIO_setLed1Color(uint32_t color) {
	uint32_t packedColor =
			((color >> 12)&0xf00)
		  | ((color >> 8)&0x0f0)
		  | ((color >> 4)&0x00f);
	pwm_reg_value = (pwm_reg_value & 0x000fffff) | (packedColor << 20);
	thereminIO_writeReg(THEREMIN_WR_REG_PWM,
			pwm_reg_value);
}

// returns Y coordinate of row which is currently being displayed
uint32_t thereminLCD_getCurrentRowIndex() {
	return thereminIO_readReg(THEREMIN_RD_REG_STATUS) & 0x3ff;
}


/*
 * Use this function to setup the interrupt environment
 * Returns XST_SUCCESS if succeeded.
 */
int thereminAudio_setUpInterruptSystem(XScuGic *InterruptController, uint16_t DeviceId);

static uint32_t status_reg_value = 0x18000000;
void thereminIO_setStatusReg(uint32_t value, uint32_t mask) {
	status_reg_value = (status_reg_value & (~mask)) | (value & mask);
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_STATUS,
			status_reg_value);
}


// Set number of stages for theremin sensor IIR filter (2..8)
void thereminSensor_setIIRFilterStages(uint32_t numberOfStages) {
	if (numberOfStages < 2)
		numberOfStages = 2;
	else if (numberOfStages > 8)
		numberOfStages = 8;
	thereminIO_setStatusReg((numberOfStages-1) << THEREMIN_REG_STATUS_IIR_STAGES_SHIFT, THEREMIN_REG_STATUS_IIR_STAGES_MASK);
}

// Returns pitch sensor output filtered value
uint32_t thereminSensor_readPitchPeriodFiltered() {
	return Xil_In32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_RD_REG_PITCH_PERIOD);
}

// Returns volume sensor output filtered value
uint32_t thereminSensor_readVolumePeriodFiltered() {
	return Xil_In32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_RD_REG_VOLUME_PERIOD);
}


/** Write to LineOut left channel */
void thereminAudio_writeLineOutL(uint32_t sample) {
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_LINE_OUT_L,
			sample);
}
/** Write to LineOut right channel */
void thereminAudio_writeLineOutR(uint32_t sample) {
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_LINE_OUT_R,
			sample);
}
/** Write to LineOut both channels (mono) */
void thereminAudio_writeLineOutLR(uint32_t sample) {
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_LINE_OUT_L,
			sample);
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_LINE_OUT_R,
			sample);
}
/** Write to PhonesOut left channel */
void thereminAudio_writePhonesOutL(uint32_t sample) {
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_PHONES_OUT_L,
			sample);
}
/** Write to PhonesOut right channel */
void thereminAudio_writePhonesOutR(uint32_t sample) {
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_PHONES_OUT_R,
			sample);
}
/** Write to PhonesOut both channels (mono) */
void thereminAudio_writePhonesOutLR(uint32_t sample) {
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_PHONES_OUT_L,
			sample);
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_PHONES_OUT_R,
			sample);
}
/** Read left channel from LineIn */
uint32_t thereminAudio_readLineInL() {
	return Xil_In32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_RD_REG_LINE_IN_L);
}
/** Read right channel from LineIn */
uint32_t thereminAudio_readLineInR() {
	return Xil_In32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_RD_REG_LINE_IN_R);
}


void thereminAudio_enableIrq()
{
	thereminIO_setStatusReg(THEREMIN_REG_STATUS_INTERRUPT_ENABLED_FLAG, THEREMIN_REG_STATUS_INTERRUPT_ENABLED_FLAG);
}

void thereminAudio_disableIrq()
{
	thereminIO_setStatusReg(0, THEREMIN_REG_STATUS_INTERRUPT_ENABLED_FLAG);
}

static void(*theremin_audio_irq_handler)() = NULL;

void thereminAudio_setIrqHandler(void(*handler)())
{
    theremin_audio_irq_handler = handler;
}

uint32_t THEREMIN_AUDIO_INTERRUPT_LATENCY; // subsample counter value on interrupt enter
uint32_t THEREMIN_AUDIO_INTERRUPT_END;     // subsample counter value on interrupt exit - ensure that audio interrupt handler is finished within 2000 subsample counter cycles

void thereminAudio_interruptHandler(void *CallbackRef) {

	u32 BaseAddress = XPAR_SCUGIC_CPU_BASEADDR;
	u32 IntID;

	/*
	 * Read the int_ack register to identify the interrupt and
	 * make sure it is valid.
	 */
	IntID = XScuGic_ReadReg(BaseAddress, XSCUGIC_INT_ACK_OFFSET) &
			    XSCUGIC_ACK_INTID_MASK;
	if(XSCUGIC_MAX_NUM_INTR_INPUTS < IntID){
		//return;
	}

	//THEREMIN_AUDIO_INTERRUPT_LATENCY = (Xil_In32(XPAR_THEREMIN_AUDIO_0_S00_AXI_BASEADDR + THEREMIN_AUDIO_STATUS_REG_OFFSET) & THEREMIN_AUDIO_STATUS_SUBSAMPLE_COUNTER_MASK)
	//		>> THEREMIN_AUDIO_STATUS_SUBSAMPLE_COUNTER_SHIFT;
	uint32_t value = Xil_In32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_RD_REG_STATUS);
	if (value & THEREMIN_REG_STATUS_INTERRUPT_PENDING_FLAG) {
		// call audio interrupt handler, if any
		if (theremin_audio_irq_handler)
			theremin_audio_irq_handler();
		// send ACK to audio board
		thereminIO_setStatusReg(0, THEREMIN_REG_STATUS_INTERRUPT_PENDING_FLAG);
	}


	//THEREMIN_AUDIO_INTERRUPT_END = (Xil_In32(XPAR_THEREMIN_AUDIO_0_S00_AXI_BASEADDR + THEREMIN_AUDIO_STATUS_REG_OFFSET) & THEREMIN_AUDIO_STATUS_SUBSAMPLE_COUNTER_MASK)
	//		>> THEREMIN_AUDIO_STATUS_SUBSAMPLE_COUNTER_SHIFT;
	/*
	 * Write to the EOI register, we are all done here.
	 * Let this function return, the boot code will restore the stack.
	 */
	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);

}

/*
 * Use this function to setup the interrupt environment
 * Returns XST_SUCCESS if succeeded.
 */
int thereminAudio_setUpInterruptSystem(XScuGic *InterruptController, uint16_t DeviceId)
{
	int Status;
	XScuGic_Config *GicConfig;

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	GicConfig = XScuGic_LookupConfig(DeviceId);
	if (NULL == GicConfig) {
		print("LookupConfig Failed\n\r");
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(InterruptController, GicConfig,
					GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		print("CfgInit Failed\n\r");
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built
	 * correctly
	 */
	Status = XScuGic_SelfTest(InterruptController);
	if (Status != XST_SUCCESS) {
		print("GIC SelfTest Failed\n\r");
		return XST_FAILURE;
	}


	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_FIQ_INT,
			//(Xil_ExceptionHandler)
			&thereminAudio_interruptHandler,
			InterruptController
			);

	/*
		 * Connect the interrupt controller interrupt handler to the hardware
		 * interrupt handling logic in the ARM processor.
		 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XScuGic_InterruptHandler,
			InterruptController);

	Xil_ExceptionEnableMask(XIL_EXCEPTION_ALL);

	return XST_SUCCESS;
}



#ifndef XSLCR_FPGA_RST_CTRL_ADDR
#define XSLCR_FPGA_RST_CTRL_ADDR (XSLCR_BASEADDR + 0x00000240U)
#endif
#ifndef XSLCR_LOCK_ADDR
#define XSLCR_LOCK_ADDR (XSLCR_BASEADDR + 0x4)
#endif
#ifndef XSLCR_LOCK_CODE
#define XSLCR_LOCK_CODE 0x0000767B
#endif
// send reset signal to PL
void thereminIO_resetPL()
{
	Xil_Out32(XSLCR_UNLOCK_ADDR, XSLCR_UNLOCK_CODE);
	uint32_t oldValue = Xil_In32(XSLCR_FPGA_RST_CTRL_ADDR) & ~0x0F;
	Xil_Out32(XSLCR_FPGA_RST_CTRL_ADDR, oldValue | 0x0F);
	// ---
	usleep(15);
	// and release the FPGA Reset Signal
	Xil_Out32(XSLCR_FPGA_RST_CTRL_ADDR, oldValue | 0x00);
	Xil_Out32(XSLCR_LOCK_ADDR, XSLCR_LOCK_CODE);
	usleep(5);
}

// Flush CPU cache
void thereminIO_flushCache(void * addr, uint32_t size) {
	Xil_DCacheFlushRange((unsigned int)addr, size);
}


XScuGic myInterruptController;
// Init all peripherials
void thereminIO_init() {
	thereminIO_resetPL();
	if (thereminAudio_setUpInterruptSystem(&myInterruptController, XPAR_PS7_SCUGIC_0_DEVICE_ID) != XST_SUCCESS) {
		// error
		print("Interrupt system initialization failed\r\n");
	}
}
