## This file is a general .xdc for the AX7035-B board by Alinx, version 1.0.
## Created by Andres A. Lopez in 2023.
## To use it in a project:
## - Uncomment the lines corresponding to used pins.
## - Rename the used ports [in each line, after get_ports] according to the top-level signal names in the project.

#Net IO Standard
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## Clock signal
set_property -dict { PACKAGE_PIN Y18    IOSTANDARD LVCMOS33 } [get_ports { CLK }]; # User to assign the correct pin
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports { CLK }];

## DDR3 Memory
# Assuming BANK34 is connected to DDR3
#set_property -dict { PACKAGE_PIN AA3   IOSTANDARD SSTL15 } [get_ports { DDR3_LDQS_N }];
#set_property -dict { PACKAGE_PIN R3    IOSTANDARD SSTL15 } [get_ports { DDR3_UDQS_P }];
#set_property -dict { PACKAGE_PIN Y3    IOSTANDARD SSTL15 } [get_ports { DDR3_LDQS_P }];
#set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL15 } [get_ports { DDR3_UDQS_N }];
#set_property -dict { PACKAGE_PIN V4    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[0] }];
#set_property -dict { PACKAGE_PIN AB2   IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[1] }];
#set_property -dict { PACKAGE_PIN AB3   IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[2] }];
#set_property -dict { PACKAGE_PIN AA1   IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[3] }];
#set_property -dict { PACKAGE_PIN AA5   IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[4] }];
#set_property -dict { PACKAGE_PIN Y4    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[5] }];
#set_property -dict { PACKAGE_PIN AB5   IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[6] }];
#set_property -dict { PACKAGE_PIN AA4   IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[7] }];
#set_property -dict { PACKAGE_PIN V2    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[8] }];
#set_property -dict { PACKAGE_PIN Y1    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[9] }];
#set_property -dict { PACKAGE_PIN U1    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[10] }];
#set_property -dict { PACKAGE_PIN Y2    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[11] }];
#set_property -dict { PACKAGE_PIN T1    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[12] }];
#set_property -dict { PACKAGE_PIN W1    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[13] }];
#set_property -dict { PACKAGE_PIN U2    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[14] }];
#set_property -dict { PACKAGE_PIN U3    IOSTANDARD SSTL15 } [get_ports { DDR3_DQ[15] }];
#set_property -dict { PACKAGE_PIN AB1   IOSTANDARD SSTL15 } [get_ports { DDR3_LDM }];
#set_property -dict { PACKAGE_PIN W2    IOSTANDARD SSTL15 } [get_ports { DDR3_UDM }];
#set_property -dict { PACKAGE_PIN AA8   IOSTANDARD SSTL15 } [get_ports { DDR3_A[0] }];
#set_property -dict { PACKAGE_PIN U5    IOSTANDARD SSTL15 } [get_ports { DDR3_A[1] }];
#set_property -dict { PACKAGE_PIN Y9    IOSTANDARD SSTL15 } [get_ports { DDR3_A[2] }];
#set_property -dict { PACKAGE_PIN Y8    IOSTANDARD SSTL15 } [get_ports { DDR3_A[3] }];
#set_property -dict { PACKAGE_PIN V5    IOSTANDARD SSTL15 } [get_ports { DDR3_A[4] }];
#set_property -dict { PACKAGE_PIN W7    IOSTANDARD SSTL15 } [get_ports { DDR3_A[5] }];
#set_property -dict { PACKAGE_PIN U6    IOSTANDARD SSTL15 } [get_ports { DDR3_A[6] }];
#set_property -dict { PACKAGE_PIN V7    IOSTANDARD SSTL15 } [get_ports { DDR3_A[7] }];
#set_property -dict { PACKAGE_PIN T5    IOSTANDARD SSTL15 } [get_ports { DDR3_A[8] }];
#set_property -dict { PACKAGE_PIN W9    IOSTANDARD SSTL15 } [get_ports { DDR3_A[9] }];
#set_property -dict { PACKAGE_PIN AA6   IOSTANDARD SSTL15 } [get_ports { DDR3_A[10] }];
#set_property -dict { PACKAGE_PIN T6    IOSTANDARD SSTL15 } [get_ports { DDR3_A[11] }];
#set_property -dict { PACKAGE_PIN Y6    IOSTANDARD SSTL15 } [get_ports { DDR3_A[12] }];
#set_property -dict { PACKAGE_PIN R6    IOSTANDARD SSTL15 } [get_ports { DDR3_A[13] }];
#set_property -dict { PACKAGE_PIN AB8   IOSTANDARD SSTL15 } [get_ports { DDR3_BA[0] }];
#set_property -dict { PACKAGE_PIN W5    IOSTANDARD SSTL15 } [get_ports { DDR3_BA[1] }];
#set_property -dict { PACKAGE_PIN Y7    IOSTANDARD SSTL15 } [get_ports { DDR3_BA[2] }];
#set_property -dict { PACKAGE_PIN U7    IOSTANDARD SSTL15 } [get_ports { DDR3_S0 }];
#set_property -dict { PACKAGE_PIN AB7   IOSTANDARD SSTL15 } [get_ports { DDR3_RAS }];
#set_property -dict { PACKAGE_PIN T4    IOSTANDARD SSTL15 } [get_ports { DDR3_CAS }];
#set_property -dict { PACKAGE_PIN W6    IOSTANDARD SSTL15 } [get_ports { DDR3_WE }];
#set_property -dict { PACKAGE_PIN AB6   IOSTANDARD SSTL15 } [get_ports { DDR3_ODT }];
#set_property -dict { PACKAGE_PIN T3    IOSTANDARD SSTL15 } [get_ports { DDR3_RESET }];
#set_property -dict { PACKAGE_PIN V9    IOSTANDARD SSTL15 } [get_ports { DDR3_CLK_P }];
#set_property -dict { PACKAGE_PIN V8    IOSTANDARD SSTL15 } [get_ports { DDR3_CLK_N }];
#set_property -dict { PACKAGE_PIN R4    IOSTANDARD SSTL15 } [get_ports { DDR3_CKE }];

## QSPI Flash
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#set_property CONFIG_MODE SPIx4 [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

#set_property -dict { PACKAGE_PIN L12   IOSTANDARD LVCMOS33 } [get_ports { QSPI_CLK }];
#set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { QSPI_CS }];
#set_property -dict { PACKAGE_PIN P22   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ0 }];
#set_property -dict { PACKAGE_PIN R22   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ1 }];
#set_property -dict { PACKAGE_PIN P21   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ2 }];
#set_property -dict { PACKAGE_PIN R21   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ3 }];

## Ethernet
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { E1_GTXC }];
#set_property -dict { PACKAGE_PIN J21   IOSTANDARD LVCMOS33 } [get_ports { E1_TXD0 }];
#set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { E1_TXD1 }];
#set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { E1_TXD2 }];
#set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS33 } [get_ports { E1_TXD3 }];
#set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { E1_TXEN }];
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { E1_RXC }];
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { E1_RXD0 }];
#set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { E1_RXD1 }];
#set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { E1_RXD2 }];
#set_property -dict { PACKAGE_PIN J20   IOSTANDARD LVCMOS33 } [get_ports { E1_RXD3 }];
#set_property -dict { PACKAGE_PIN M21   IOSTANDARD LVCMOS33 } [get_ports { E1_RXDV }];
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { E1_MDC }];
#set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { E1_MDIO }];
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { E1_RESET }];

## HDMI Out
#set_property -dict { PACKAGE_PIN E1    IOSTANDARD TMDS_33 } [get_ports { HDMI1_CLK_P }];
#set_property -dict { PACKAGE_PIN D1    IOSTANDARD TMDS_33 } [get_ports { HDMI1_CLK_N }];
#set_property -dict { PACKAGE_PIN G1    IOSTANDARD TMDS_33 } [get_ports { HDMI1_D0_P }];
#set_property -dict { PACKAGE_PIN F1    IOSTANDARD TMDS_33 } [get_ports { HDMI1_D0_N }];
#set_property -dict { PACKAGE_PIN H2    IOSTANDARD TMDS_33 } [get_ports { HDMI1_D1_P }];
#set_property -dict { PACKAGE_PIN G2    IOSTANDARD TMDS_33 } [get_ports { HDMI1_D1_N }];
#set_property -dict { PACKAGE_PIN K1    IOSTANDARD TMDS_33 } [get_ports { HDMI1_D2_P }];
#set_property -dict { PACKAGE_PIN J1    IOSTANDARD TMDS_33 } [get_ports { HDMI1_D2_N }];
#set_property -dict { PACKAGE_PIN P4    IOSTANDARD LVCMOS33 } [get_ports { HDMI1_SCL }];
#set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports { HDMI1_SDA }];
#set_property -dict { PACKAGE_PIN M6    IOSTANDARD LVCMOS33 } [get_ports { HDMI1_OUT_EN }];
#set_property -dict { PACKAGE_PIN P5    IOSTANDARD LVCMOS33 } [get_ports { HDMI1_5V }];
#set_property -dict { PACKAGE_PIN M5    IOSTANDARD LVCMOS33 } [get_ports { HDMI1_HPD }];

## HDMI In
#set_property -dict { PACKAGE_PIN K4    IOSTANDARD TMDS_33 } [get_ports { HDMI2_CLK_P }];
#set_property -dict { PACKAGE_PIN J4    IOSTANDARD TMDS_33 } [get_ports { HDMI2_CLK_N }];
#set_property -dict { PACKAGE_PIN M1    IOSTANDARD TMDS_33 } [get_ports { HDMI2_D0_P }];
#set_property -dict { PACKAGE_PIN L1    IOSTANDARD TMDS_33 } [get_ports { HDMI2_D0_N }];
#set_property -dict { PACKAGE_PIN P2    IOSTANDARD TMDS_33 } [get_ports { HDMI2_D1_P }];
#set_property -dict { PACKAGE_PIN N2    IOSTANDARD TMDS_33 } [get_ports { HDMI2_D1_N }];
#set_property -dict { PACKAGE_PIN R1    IOSTANDARD TMDS_33 } [get_ports { HDMI2_D2_P }];
#set_property -dict { PACKAGE_PIN P1    IOSTANDARD TMDS_33 } [get_ports { HDMI2_D2_N }];
#set_property -dict { PACKAGE_PIN N5    IOSTANDARD LVCMOS33 } [get_ports { HDMI2_SCL }];
#set_property -dict { PACKAGE_PIN L6    IOSTANDARD LVCMOS33 } [get_ports { HDMI2_SDA }];
#set_property -dict { PACKAGE_PIN P6    IOSTANDARD LVCMOS33 } [get_ports { HDMI2_OUT_EN }];
#set_property -dict { PACKAGE_PIN M5    IOSTANDARD LVCMOS33 } [get_ports { HDMI2_HPD }];

## USB
#set_property -dict { PACKAGE_PIN H18    IOSTANDARD LVCMOS33 } [get_ports { USB_FD3 }];
#set_property -dict { PACKAGE_PIN H22    IOSTANDARD LVCMOS33 } [get_ports { USB_FD4 }];
#set_property -dict { PACKAGE_PIN J15    IOSTANDARD LVCMOS33 } [get_ports { USB_FD5 }];
#set_property -dict { PACKAGE_PIN H20    IOSTANDARD LVCMOS33 } [get_ports { USB_FD6 }];
#set_property -dict { PACKAGE_PIN G20    IOSTANDARD LVCMOS33 } [get_ports { USB_FD7 }];
#set_property -dict { PACKAGE_PIN H19    IOSTANDARD LVCMOS33 } [get_ports { USB_RXF }];
#set_property -dict { PACKAGE_PIN H15    IOSTANDARD LVCMOS33 } [get_ports { USB_TXE }];
#set_property -dict { PACKAGE_PIN L21    IOSTANDARD LVCMOS33 } [get_ports { USB_RD }];
#set_property -dict { PACKAGE_PIN G17    IOSTANDARD LVCMOS33 } [get_ports { USB_WR }];
#set_property -dict { PACKAGE_PIN H17    IOSTANDARD LVCMOS33 } [get_ports { USB_SIWUA }];
#set_property -dict { PACKAGE_PIN J19    IOSTANDARD LVCMOS33 } [get_ports { USB_CLKOUT }];
#set_property -dict { PACKAGE_PIN G18    IOSTANDARD LVCMOS33 } [get_ports { USB_OE }];

## SD Card
#set_property -dict { PACKAGE_PIN P16    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT0 }];
#set_property -dict { PACKAGE_PIN R17    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT1 }];
#set_property -dict { PACKAGE_PIN N14    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT2 }];
#set_property -dict { PACKAGE_PIN N13    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT3 }];
#set_property -dict { PACKAGE_PIN R16    IOSTANDARD LVCMOS33 } [get_ports { SD_CD_N }];

## UART
set_property -dict { PACKAGE_PIN G15    IOSTANDARD LVCMOS33 } [get_ports { rx }];
set_property -dict { PACKAGE_PIN G16    IOSTANDARD LVCMOS33 } [get_ports { tx }];

## EEPROM I2C
#set_property -dict { PACKAGE_PIN N18    IOSTANDARD LVCMOS33 } [get_ports { EEPROM_I2C_SCL }];
#set_property -dict { PACKAGE_PIN N19    IOSTANDARD LVCMOS33 } [get_ports { EEPROM_I2C_SDA }];

## 7-Segment Displays
set_property -dict { PACKAGE_PIN J5     IOSTANDARD LVCMOS33 } [get_ports { OUT_DP[6] }];
set_property -dict { PACKAGE_PIN M3     IOSTANDARD LVCMOS33 } [get_ports { OUT_DP[5] }];
set_property -dict { PACKAGE_PIN J6     IOSTANDARD LVCMOS33 } [get_ports { OUT_DP[4] }];
set_property -dict { PACKAGE_PIN H5     IOSTANDARD LVCMOS33 } [get_ports { OUT_DP[3] }];
set_property -dict { PACKAGE_PIN G4     IOSTANDARD LVCMOS33 } [get_ports { OUT_DP[2] }];
set_property -dict { PACKAGE_PIN K6     IOSTANDARD LVCMOS33 } [get_ports { OUT_DP[1] }];
set_property -dict { PACKAGE_PIN K3     IOSTANDARD LVCMOS33 } [get_ports { OUT_DP[0] }];
set_property -dict { PACKAGE_PIN H4     IOSTANDARD LVCMOS33 } [get_ports { OUT_DP[7] }];

set_property -dict { PACKAGE_PIN M2     IOSTANDARD LVCMOS33 } [get_ports { dp_sel[0] }];
set_property -dict { PACKAGE_PIN N4     IOSTANDARD LVCMOS33 } [get_ports { dp_sel[1] }];
set_property -dict { PACKAGE_PIN L5     IOSTANDARD LVCMOS33 } [get_ports { dp_sel[2] }];
set_property -dict { PACKAGE_PIN L4     IOSTANDARD LVCMOS33 } [get_ports { dp_sel[3] }];
set_property -dict { PACKAGE_PIN M16    IOSTANDARD LVCMOS33 } [get_ports { dp_sel[4] }];
set_property -dict { PACKAGE_PIN M17    IOSTANDARD LVCMOS33 } [get_ports { dp_sel[5] }];

## Temperature Sensor [LM75]
#set_property -dict { PACKAGE_PIN M22    IOSTANDARD LVCMOS33 } [get_ports { LM75_SCL }];
#set_property -dict { PACKAGE_PIN N22    IOSTANDARD LVCMOS33 } [get_ports { LM75_SDA }];

## GPIOs J9 and J10
#set_property -dict { PACKAGE_PIN D16    IOSTANDARD LVCMOS33 } [get_ports { LED_out[0] }];
#set_property -dict { PACKAGE_PIN E16    IOSTANDARD LVCMOS33 } [get_ports { J9_4_IO }];
#set_property -dict { PACKAGE_PIN F14    IOSTANDARD LVCMOS33 } [get_ports { LED_out[1] }];
#set_property -dict { PACKAGE_PIN F13    IOSTANDARD LVCMOS33 } [get_ports { J9_6_IO }];
#set_property -dict { PACKAGE_PIN E14    IOSTANDARD LVCMOS33 } [get_ports { LED_out[2] }];
#set_property -dict { PACKAGE_PIN E13    IOSTANDARD LVCMOS33 } [get_ports { J9_8_IO }];
#set_property -dict { PACKAGE_PIN D15    IOSTANDARD LVCMOS33 } [get_ports { LED_out[3] }];
#set_property -dict { PACKAGE_PIN D14    IOSTANDARD LVCMOS33 } [get_ports { J9_10_IO }];
#set_property -dict { PACKAGE_PIN B13    IOSTANDARD LVCMOS33 } [get_ports { LED_out[4] }];
#set_property -dict { PACKAGE_PIN C13    IOSTANDARD LVCMOS33 } [get_ports { Button_in }];
#set_property -dict { PACKAGE_PIN A14    IOSTANDARD LVCMOS33 } [get_ports { LED_out[5] }];
#set_property -dict { PACKAGE_PIN A13    IOSTANDARD LVCMOS33 } [get_ports { Opcode_in[0] }];
#set_property -dict { PACKAGE_PIN C15    IOSTANDARD LVCMOS33 } [get_ports { LED_out[6] }];
#set_property -dict { PACKAGE_PIN C14    IOSTANDARD LVCMOS33 } [get_ports { Opcode_in[1] }];
#set_property -dict { PACKAGE_PIN A16    IOSTANDARD LVCMOS33 } [get_ports { LED_out[7] }];
#set_property -dict { PACKAGE_PIN A15    IOSTANDARD LVCMOS33 } [get_ports { Opcode_in[2] }];
#set_property -dict { PACKAGE_PIN B16    IOSTANDARD LVCMOS33 } [get_ports { J9_19_IO }];
#set_property -dict { PACKAGE_PIN B15    IOSTANDARD LVCMOS33 } [get_ports { DISP_SW }];
#set_property -dict { PACKAGE_PIN B18    IOSTANDARD LVCMOS33 } [get_ports { J9_21_IO }];
#set_property -dict { PACKAGE_PIN B17    IOSTANDARD LVCMOS33 } [get_ports { Data_in[0] }];
#set_property -dict { PACKAGE_PIN A19    IOSTANDARD LVCMOS33 } [get_ports { J9_23_IO }];
#set_property -dict { PACKAGE_PIN A18    IOSTANDARD LVCMOS33 } [get_ports { Data_in[1] }];
#set_property -dict { PACKAGE_PIN C19    IOSTANDARD LVCMOS33 } [get_ports { J9_25_IO }];
#set_property -dict { PACKAGE_PIN C18    IOSTANDARD LVCMOS33 } [get_ports { Data_in[2] }];
#set_property -dict { PACKAGE_PIN A20    IOSTANDARD LVCMOS33 } [get_ports { J9_27_IO }];
#set_property -dict { PACKAGE_PIN B20    IOSTANDARD LVCMOS33 } [get_ports { Data_in[3] }];
#set_property -dict { PACKAGE_PIN C17    IOSTANDARD LVCMOS33 } [get_ports { J9_29_IO }];
#set_property -dict { PACKAGE_PIN D17    IOSTANDARD LVCMOS33 } [get_ports { Data_in[4] }];
#set_property -dict { PACKAGE_PIN D19    IOSTANDARD LVCMOS33 } [get_ports { J9_31_IO }];
#set_property -dict { PACKAGE_PIN E19    IOSTANDARD LVCMOS33 } [get_ports { Data_in[5] }];
#set_property -dict { PACKAGE_PIN E18    IOSTANDARD LVCMOS33 } [get_ports { J9_33_IO }];
#set_property -dict { PACKAGE_PIN F18    IOSTANDARD LVCMOS33 } [get_ports { Data_in[6] }];
#set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { J9_35_IO }];
#set_property -dict { PACKAGE_PIN F16    IOSTANDARD LVCMOS33 } [get_ports { Data_in[7] }];

#set_property -dict { PACKAGE_PIN P17    IOSTANDARD LVCMOS33 } [get_ports { J10_3_IO }];
#set_property -dict { PACKAGE_PIN N17    IOSTANDARD LVCMOS33 } [get_ports { J10_4_IO }];
#set_property -dict { PACKAGE_PIN R19    IOSTANDARD LVCMOS33 } [get_ports { J10_5_IO }];
#set_property -dict { PACKAGE_PIN P19    IOSTANDARD LVCMOS33 } [get_ports { J10_6_IO }];
#set_property -dict { PACKAGE_PIN T18    IOSTANDARD LVCMOS33 } [get_ports { J10_7_IO }];
#set_property -dict { PACKAGE_PIN R18    IOSTANDARD LVCMOS33 } [get_ports { J10_8_IO }];
#set_property -dict { PACKAGE_PIN U21    IOSTANDARD LVCMOS33 } [get_ports { J10_9_IO }];
#set_property -dict { PACKAGE_PIN T21    IOSTANDARD LVCMOS33 } [get_ports { J10_10_IO }];
#set_property -dict { PACKAGE_PIN V22    IOSTANDARD LVCMOS33 } [get_ports { J10_11_IO }];
#set_property -dict { PACKAGE_PIN U22    IOSTANDARD LVCMOS33 } [get_ports { J10_12_IO }];
#set_property -dict { PACKAGE_PIN V20    IOSTANDARD LVCMOS33 } [get_ports { J10_13_IO }];
#set_property -dict { PACKAGE_PIN U20    IOSTANDARD LVCMOS33 } [get_ports { J10_14_IO }];
#set_property -dict { PACKAGE_PIN W22    IOSTANDARD LVCMOS33 } [get_ports { J10_15_IO }];
#set_property -dict { PACKAGE_PIN W21    IOSTANDARD LVCMOS33 } [get_ports { J10_16_IO }];
#set_property -dict { PACKAGE_PIN Y22    IOSTANDARD LVCMOS33 } [get_ports { J10_17_IO }];
#set_property -dict { PACKAGE_PIN Y21    IOSTANDARD LVCMOS33 } [get_ports { J10_18_IO }];
#set_property -dict { PACKAGE_PIN AA21   IOSTANDARD LVCMOS33 } [get_ports { J10_19_IO }];
#set_property -dict { PACKAGE_PIN AA20   IOSTANDARD LVCMOS33 } [get_ports { J10_20_IO }];
#set_property -dict { PACKAGE_PIN AB22   IOSTANDARD LVCMOS33 } [get_ports { J10_21_IO }];
#set_property -dict { PACKAGE_PIN AB21   IOSTANDARD LVCMOS33 } [get_ports { J10_22_IO }];
#set_property -dict { PACKAGE_PIN AB20   IOSTANDARD LVCMOS33 } [get_ports { J10_23_IO }];
#set_property -dict { PACKAGE_PIN AA19   IOSTANDARD LVCMOS33 } [get_ports { J10_24_IO }];
#set_property -dict { PACKAGE_PIN W20    IOSTANDARD LVCMOS33 } [get_ports { J10_25_IO }];
#set_property -dict { PACKAGE_PIN W19    IOSTANDARD LVCMOS33 } [get_ports { J10_26_IO }];
#set_property -dict { PACKAGE_PIN AB18   IOSTANDARD LVCMOS33 } [get_ports { J10_27_IO }];
#set_property -dict { PACKAGE_PIN AA18   IOSTANDARD LVCMOS33 } [get_ports { J10_28_IO }];
#set_property -dict { PACKAGE_PIN V19    IOSTANDARD LVCMOS33 } [get_ports { J10_29_IO }];
#set_property -dict { PACKAGE_PIN V18    IOSTANDARD LVCMOS33 } [get_ports { J10_30_IO }];
#set_property -dict { PACKAGE_PIN W17    IOSTANDARD LVCMOS33 } [get_ports { J10_31_IO }];
#set_property -dict { PACKAGE_PIN V17    IOSTANDARD LVCMOS33 } [get_ports { J10_32_IO }];
#set_property -dict { PACKAGE_PIN U18    IOSTANDARD LVCMOS33 } [get_ports { J10_33_IO }];
#set_property -dict { PACKAGE_PIN U17    IOSTANDARD LVCMOS33 } [get_ports { J10_34_IO }];
#set_property -dict { PACKAGE_PIN R14    IOSTANDARD LVCMOS33 } [get_ports { J10_35_IO }];
#set_property -dict { PACKAGE_PIN P14    IOSTANDARD LVCMOS33 } [get_ports { J10_36_IO }];

## FPC Connector
#set_property -dict { PACKAGE_PIN D2     IOSTANDARD LVCMOS33 } [get_ports { FPC_MIPI_LAN0_N }];
#set_property -dict { PACKAGE_PIN E2     IOSTANDARD LVCMOS33 } [get_ports { FPC_MIPI_LAN0_P }];
#set_property -dict { PACKAGE_PIN E3     IOSTANDARD LVCMOS33 } [get_ports { FPC_MIPI_LAN1_N }];
#set_property -dict { PACKAGE_PIN F3     IOSTANDARD LVCMOS33 } [get_ports { FPC_MIPI_LAN1_P }];
#set_property -dict { PACKAGE_PIN G3     IOSTANDARD LVCMOS33 } [get_ports { FPC_MIPI_CLK_N }];
#set_property -dict { PACKAGE_PIN H3     IOSTANDARD LVCMOS33 } [get_ports { FPC_MIPI_CLK_P }];
#set_property -dict { PACKAGE_PIN H13    IOSTANDARD LVCMOS33 } [get_ports { FPC_CAM_GPIO }];
#set_property -dict { PACKAGE_PIN H14    IOSTANDARD LVCMOS33 } [get_ports { FPC_CAM_CLK }];
#set_property -dict { PACKAGE_PIN J14    IOSTANDARD LVCMOS33 } [get_ports { FPC_CAM_SCL }];
#set_property -dict { PACKAGE_PIN G13    IOSTANDARD LVCMOS33 } [get_ports { FPC_CAM_SDA }];

## LEDs
set_property -dict { PACKAGE_PIN F19    IOSTANDARD LVCMOS33 } [get_ports { n_Flags[1] }];
set_property -dict { PACKAGE_PIN E21    IOSTANDARD LVCMOS33 } [get_ports { n_Flags[3] }];
set_property -dict { PACKAGE_PIN D20    IOSTANDARD LVCMOS33 } [get_ports { n_Flags[0] }];
set_property -dict { PACKAGE_PIN C20    IOSTANDARD LVCMOS33 } [get_ports { n_Flags[2] }];

## Buttons
set_property -dict { PACKAGE_PIN M13    IOSTANDARD LVCMOS33 } [get_ports { kminus }];
set_property -dict { PACKAGE_PIN K14    IOSTANDARD LVCMOS33 } [get_ports { H_L }];
set_property -dict { PACKAGE_PIN K13    IOSTANDARD LVCMOS33 } [get_ports { kplus }];
#set_property -dict { PACKAGE_PIN L13    IOSTANDARD LVCMOS33 } [get_ports { kplus }];

## Miscellaneous
set_property -dict { PACKAGE_PIN F20    IOSTANDARD LVCMOS33 } [get_ports { RESET }];