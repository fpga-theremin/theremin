#include "theremin_ip.h"


#include <xil_types.h>
#include <xstatus.h>
#include <xscugic.h>
#include <sleep.h>
#include <xil_io.h>
#include <xil_misc_psreset_api.h>
#include <xil_cache.h>
#include <xil_cache_l.h>
#include <xpseudo_asm.h>
#include <xil_mmu.h>

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

//uint32_t pwm_reg_value = 0x000000ff;
#define pwm_reg_value (*(volatile uint32_t *)(0xFFFF0010))


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


static uint32_t audio_status_reg_value = 0x00000000;
void thereminAudio_setStatusReg(uint32_t value, uint32_t mask) {
	audio_status_reg_value = (audio_status_reg_value & (~mask)) | (value & mask);
	Xil_Out32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_AUDIO_STATUS,
			audio_status_reg_value);
}



/** read audio status reg 
              [31] is audio IRQ enable 
              [30] is pending IRQ
           [29:12] is sample count
            [11:0] is subsample count
*/
uint32_t thereminAudio_getStatus() {
    audio_status_reg_value = Xil_In32(XPAR_THEREMIN_IO_IP_0_BASEADDR + THEREMIN_WR_REG_AUDIO_STATUS);
    return audio_status_reg_value;
}

void thereminAudio_enableIrq()
{
    thereminAudio_setStatusReg(THEREMIN_REG_AUDIO_STATUS_INTERRUPT_ENABLED_FLAG, THEREMIN_REG_AUDIO_STATUS_INTERRUPT_ENABLED_FLAG);
}

void thereminAudio_disableIrq()
{
    thereminAudio_setStatusReg(0, THEREMIN_REG_AUDIO_STATUS_INTERRUPT_ENABLED_FLAG);
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
	uint32_t value = thereminAudio_getStatus();
	if (value & THEREMIN_REG_AUDIO_STATUS_INTERRUPT_PENDING_FLAG) {
		// call audio interrupt handler, if any
		if (theremin_audio_irq_handler)
			theremin_audio_irq_handler();
		// send ACK to audio board
		thereminAudio_setStatusReg(0, THEREMIN_REG_AUDIO_STATUS_INTERRUPT_PENDING_FLAG);
	}


	//THEREMIN_AUDIO_INTERRUPT_END = (Xil_In32(XPAR_THEREMIN_AUDIO_0_S00_AXI_BASEADDR + THEREMIN_AUDIO_STATUS_REG_OFFSET) & THEREMIN_AUDIO_STATUS_SUBSAMPLE_COUNTER_MASK)
	//		>> THEREMIN_AUDIO_STATUS_SUBSAMPLE_COUNTER_SHIFT;
	/*
	 * Write to the EOI register, we are all done here.
	 * Let this function return, the boot code will restore the stack.
	 */
	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);

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


#define COMM_VAL (*(volatile uint32_t *)(0xFFFF0000))
#define CPU1_START_ADDR 0xfffffff0


#if (XPAR_CPU_ID == 0)


#define INTC		    XScuGic
#define INTC_DEVICE_ID	XPAR_PS7_SCUGIC_0_DEVICE_ID
#define INTC_HANDLER	XScuGic_InterruptHandler

static int  SetupIntrSystem(INTC *IntcInstancePtr);
INTC   IntcInstancePtr;

/*****************************************************************************/
/**
*
* This function setups initializes the interrupt system.
*
* @param	IntcInstancePtr is a pointer to the instance of the Intc driver.
* @param	PeriphInstancePtr is a pointer to the instance of peripheral driver.
* @param	IntrId is the Interrupt Id of the peripheral interrupt
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
static int SetupIntrSystem(INTC *IntcInstancePtr)
{
	int Status;


	XScuGic_Config *IntcConfig;

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
					IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Initialize the  exception table
	 */
	Xil_ExceptionInit();

	/*
	 * Register the interrupt controller handler with the exception table
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			 (Xil_ExceptionHandler)INTC_HANDLER,
			 IntcInstancePtr);

	/*
	 * Enable non-critical exceptions
	 */
	Xil_ExceptionEnable();


	return XST_SUCCESS;
}


#define sev() __asm__ __volatile__ ("dmb" : : : "memory")
#define wfe() __asm__ __volatile__ ("wfe" : : : "memory")
int thereminIO_startCPU1() {
	uint32_t startup_address = 0x00200000;
	print("CPU0 starting CPU1\r\n");
	COMM_VAL = 1;
	thereminIO_setLed0Color(0x000080);
	Xil_Out32(CPU1_START_ADDR, startup_address);
	Xil_DCacheFlushLine(CPU1_START_ADDR); // OCM is still cacheable!
	dsb();
	dmb();
	sev();
	thereminIO_setLed0Color(0x606000);
	for(int i = 0; i < 1000000; i++) {
		//dmb();
		//wfe();
		if (COMM_VAL == 2)
			return 1;
	}
	return 0;
}

int thereminIO_initCPU0() {
	COMM_VAL = 0;
	print("Going to reset PL\r\n");
	thereminIO_resetPL();
	print("PL reset done\r\n");
	thereminIO_setLed0Color(0xf00000);
	// Initialize the SCU Interrupt Distributer (ICD)
	int Status = 0;
	Status = SetupIntrSystem(&IntcInstancePtr);
	if (Status != XST_SUCCESS) {
			return XST_FAILURE;
	}
	thereminIO_setLed0Color(0x00f000);
	print("Interrupt controller initialized\r\n");

	Status = thereminIO_startCPU1();
	thereminIO_setLed0Color(0x0000f0);
	print("CPU1 started\r\n");

	thereminIO_setLed0Color(0xf0f0f0);

	return Status;
}
#else

/*
 * Use this function to setup the interrupt environment
 * Returns XST_SUCCESS if succeeded.
 */
int thereminAudio_setUpInterruptSystem(XScuGic *InterruptController, uint16_t DeviceId);


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


XScuGic myInterruptController;
int thereminIO_initCPU1() {
	//thereminIO_setLed1Color(0x004040);
	//print("CPU1 waiting for CPU0\r\n");

	while (COMM_VAL != 1)
		;
	//print("CPU1 got start signal\r\n");
	COMM_VAL = 2;
	Xil_DCacheFlushLine(CPU1_START_ADDR); // OCM is still cacheable!
	if (thereminAudio_setUpInterruptSystem(&myInterruptController, XPAR_PS7_SCUGIC_0_DEVICE_ID) != XST_SUCCESS) {
		// error
		thereminIO_setLed1Color(0xf00000);
		//print("Interrupt system initialization failed\r\n");
		return 0;
	}
	return 1;
}

#endif



// Init all peripherials
void thereminIO_init() {

	//Disable cache on OCM
	Xil_SetTlbAttributes(0xFFFF0000,0x14de2);           // S=b1 TEX=b100 AP=b11, Domain=b1111, C=b0, B=b0
	Xil_SetTlbAttributes(0x00000000,0x14de2);           // S=b1 TEX=b100 AP=b11, Domain=b1111, C=b0, B=b0
	Xil_SetTlbAttributes(0x00010000,0x14de2);           // S=b1 TEX=b100 AP=b11, Domain=b1111, C=b0, B=b0
	Xil_SetTlbAttributes(0x00020000,0x14de2);           // S=b1 TEX=b100 AP=b11, Domain=b1111, C=b0, B=b0


#if (XPAR_CPU_ID == 0)

	thereminIO_initCPU0();


#else

	thereminIO_initCPU1();

#endif
}
