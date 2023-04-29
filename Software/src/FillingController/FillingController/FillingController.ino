// brausteuerung@AndreBetz.de
// hier gilt die Bierlizenz
///////////////////////////////////////////////
// includes
///////////////////////////////////////////////
#include <LiquidCrystal.h>
#include "DbgConsole.h"
#include "WaitTime.h"
#include "storage.h"
///////////////////////////////////////////////
// defines
///////////////////////////////////////////////
//#define NO_CONSOLE
#define SENSORSIM
#define MAXBUTTONS          6
#define PINLCD              10
#define PINKEY              0
#define PINWATER            1
#define PINGE               13  //D13
#define PINGA               12  //D12
#define PINBE               11  //D11
#define DEFGASSPUELEN       2000
#define DEFGASFUELLEN       2000
#define DEFBIERRUHE         2000
#define DEFTOWATER          500
#define VENTILZU            false
#define VENTILAUF           true
///////////////////////////////////////////////
// ENUMS
///////////////////////////////////////////////
enum STATES
{
  STATE_START = 1,
  STATE_CO2SPUELEN,
  STATE_CO2FUELLEN,
  STATE_BIERFUELLEN,
  STATE_PRUEFEVOLL,
  STATE_FLASCHEVOLL,
  STATE_ENDE
};
enum MENU
{
  MENU_SELECT = 1,
  MENU_SETUP
};
enum BUTTONS
{
  BUTTON_UP = 1,
  BUTTON_DOWN,
  BUTTON_RIGHT,
  BUTTON_LEFT,
  BUTTON_SELECT
};
///////////////////////////////////////////////
// STRUCTS
///////////////////////////////////////////////
struct Times
{
  unsigned long gasSpuelen;
  unsigned long gasFuellen;
  unsigned long bierRuhe;
  int toWater;
  bool UseDefault;  
} fillTimes;
struct Ventile
{
  bool GasEin;  
  bool GasAus;
  bool BierEin;
} statesVentile;
///////////////////////////////////////////////
// VARIABLES
///////////////////////////////////////////////
int actState = STATE_START;
int actMenu  = MENU_SELECT;
int subMenuSelect = 0;
bool   btnPressed[MAXBUTTONS]    = {false, false, false, false, false, false};
LiquidCrystal     lcd(8, 9, 4, 5, 6, 7);
StorageEEProm     store;
WaitTime          timerGasSpuelen;
WaitTime          timerGasFuellen;
WaitTime          timerBierRuhe;
///////////////////////////////////////////////////////////////////////////////
// setDefaultValues
///////////////////////////////////////////////////////////////////////////////
void LoadValues()
{
  CONSOLELN("LoadValues");
  fillTimes.UseDefault = false;
  store.load(0, sizeof(Times), (char*)&fillTimes);
#ifdef USEDEFAULTS  
  if (  false == fillTimes.UseDefault )
#endif
  {
    // only go here after first installation
    memset((char*)&fillTimes, 0, sizeof(Times));
    fillTimes.gasSpuelen   = DEFGASSPUELEN;
    fillTimes.gasFuellen   = DEFGASFUELLEN;
    fillTimes.bierRuhe     = DEFBIERRUHE;
    fillTimes.toWater      = DEFTOWATER;
    fillTimes.UseDefault   = true;

    store.save(0, sizeof(Times), (char*)&fillTimes);
  }
  CONSOLE(F("gS:"));
  CONSOLELN(fillTimes.gasSpuelen);
  CONSOLE(F("gF:"));
  CONSOLELN(fillTimes.gasFuellen);
  CONSOLE(F("bR:"));
  CONSOLELN(fillTimes.bierRuhe);
  CONSOLE(F("to:"));
  CONSOLELN(fillTimes.toWater);

  statesVentile.BierEin = false;
  statesVentile.GasAus = false;
  statesVentile.GasEin = false;
}
///////////////////////////////////////////////////////////////////////////////
// sync lcd
///////////////////////////////////////////////////////////////////////////////
void lcdSync()
{
  lcd.begin(16, 2);  
}
///////////////////////////////////////////////////////////////////////////////
// print Logo
///////////////////////////////////////////////////////////////////////////////
void printLogo()
{
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(F("Brauverein.org"));
  delay(2000);
  lcd.clear();
}
///////////////////////////////////////////////////////////////////////////////
// readKeyPad
///////////////////////////////////////////////////////////////////////////////
void resetButtons()
{
  for ( int btnNr = 0; btnNr < MAXBUTTONS; btnNr++)
  {
    btnPressed[btnNr] = false;
  }
}
void setButton(int btnNr)
{
  if ( MAXBUTTONS > btnNr  && 0 != btnNr )
  {
    if ( false == btnPressed[btnNr] )
    {
      btnPressed[btnNr] = true;
      CONSOLE(F("b"));
      CONSOLELN(btnNr);
    }
  }
}
bool isButtonPressed(int btnNr)
{
  bool pressed = false;
  if ( MAXBUTTONS > btnNr )
  {
    pressed = btnPressed[btnNr];
    btnPressed[btnNr] = false;
  }
  return pressed;
}
int Keypad()
{
  int x;
  int y;
  int val = 0;
  int val_old = 0;

  do
  {
    val_old = val;
    x = analogRead(PINKEY);
    if      (x <  60) val = BUTTON_RIGHT;
    else if (x < 200) val = BUTTON_UP;
    else if (x < 400) val = BUTTON_DOWN;
    else if (x < 600) val = BUTTON_LEFT;
    else if (x < 800) val = BUTTON_SELECT;
    else              val = 0;
    delay(10);
  }
  while ( val != val_old );

  setButton(val);
  if ( 0 < val ) delay(200);
  return val;
}
///////////////////////////////////////////////////////////////////////////////
// menubuttons
///////////////////////////////////////////////////////////////////////////////
bool SubStateChange(int maxStates)
{
  bool getOK = false;
  if ( isButtonPressed (BUTTON_UP) )
  {
    CONSOLE(F("U"));
    subMenuSelect++;
    if ( subMenuSelect == maxStates )
      subMenuSelect = 0;
  }
  else if ( isButtonPressed (BUTTON_DOWN) )
  {
    CONSOLE(F("D"));
    if ( 0 == subMenuSelect )
    {
      subMenuSelect = maxStates - 1;
    }
    else
    {
      subMenuSelect--;
    }
  }
  else if ( isButtonPressed (BUTTON_LEFT) )
  {
    CONSOLE(F("O"));
    getOK = true;
  }
  return getOK;
}
///////////////////////////////////////////////////////////////////////////////
// restart
///////////////////////////////////////////////////////////////////////////////
void restart()
{
  actMenu = MENU_SELECT;
  actState = STATE_START;
  subMenuSelect = 0;
  GasEinlass(VENTILZU);
  if ( 0 < fillTimes.bierRuhe )
    GasAuslass(VENTILAUF);
  else
    GasAuslass(VENTILZU);
  BierEinlass(VENTILZU);
  timerBierRuhe.init();
  timerGasFuellen.init();
  timerGasSpuelen.init();
  resetButtons();
}
void GasEinlass(bool onOf)
{
  if ( statesVentile.GasEin != onOf )
  {
    CONSOLE(F("GE:"));
    statesVentile.GasEin = onOf;
    digitalWrite(PINGE, onOf ? HIGH : LOW);
    if (onOf)  CONSOLELN(F("on")); else CONSOLELN(F("off"));
  }
}
void GasAuslass(bool onOf)
{
  if ( statesVentile.GasAus != onOf )
  {
    CONSOLE(F("GA:"));
    statesVentile.GasAus = onOf;
    digitalWrite(PINGA, onOf ? HIGH : LOW);
    if (onOf)  CONSOLELN(F("on")); else CONSOLELN(F("off"));
  }
}
void BierEinlass(bool onOf)
{
  if ( statesVentile.BierEin != onOf )
  {
    CONSOLE(F("BE:"));
    statesVentile.BierEin = onOf;
    digitalWrite(PINBE, onOf ? HIGH : LOW);
    if (onOf)  CONSOLELN(F("on")); else CONSOLELN(F("off"));
  }
}
///////////////////////////////////////////////////////////////////////////////
// isSensorKontakt
///////////////////////////////////////////////////////////////////////////////
bool isSensorKontakt()
{
  bool ret = false;
#ifdef SENSORSIM
  ret = isButtonPressed(BUTTON_RIGHT);
#else
  int x;
  int val = 0;
  int val_old = 0;

  do
  {
    val_old = val;
    val = analogRead(PINWATER);
    delay(10);
  }
  while ( val != val_old );

  if ( fillTimes.toWater > val )
  {
    ret = true;
    CONSOLELN(F("SensorOn"));
  }
  
#endif
  return ret;
}
///////////////////////////////////////////////////////////////////////////////
// setup
///////////////////////////////////////////////////////////////////////////////
void setup() {
  Serial.begin(115200);
  pinMode(PINLCD,         OUTPUT);
  pinMode(PINGE,          OUTPUT);
  pinMode(PINGA,          OUTPUT);
  pinMode(PINBE,          OUTPUT);
  pinMode(PINWATER,       INPUT);
  lcdSync();
  LoadValues();
  digitalWrite(PINLCD, HIGH);
  restart();
  printLogo();
  timerGasSpuelen.setTime(fillTimes.gasSpuelen);
  timerGasFuellen.setTime(fillTimes.gasSpuelen);
  timerBierRuhe.setTime(fillTimes.bierRuhe);
}
///////////////////////////////////////////////////////////////////////////////
// menu
///////////////////////////////////////////////////////////////////////////////
void menu()
{
  lcd.setCursor(0, 0);
  if ( MENU_SELECT == actMenu )
  {
    if ( true == SubStateChange(2) )
    {
      switch ( subMenuSelect )
      {
        case 0:
          actState = STATE_CO2SPUELEN;
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print(F("CO2SPUELEN"));
          CONSOLELN(F("CO2SPUELEN"));
          break;
        case 1:
          break;
      }
    }
    else
    {
      lcd.print(F("Menu"));
      lcd.setCursor(0, 1);
      switch ( subMenuSelect )
      {
        case 0:
          lcd.print(F("Start"));
          break;
        case 1:
          lcd.print(F("Setup"));
          break;
      }
    }
  }
  else if ( MENU_SETUP == actMenu )
  {

  }
}
///////////////////////////////////////////////////////////////////////////////
// loop
///////////////////////////////////////////////////////////////////////////////
void loop() {
  Keypad();
  if ( STATE_START == actState )
  {    
    menu();
  } 
  else if ( STATE_CO2SPUELEN == actState )
  {
    GasAuslass(VENTILAUF);
    GasEinlass(VENTILAUF);
    BierEinlass(VENTILZU);
    timerGasSpuelen.start();
    if ( timerGasSpuelen.timeOver() )
    {
      GasAuslass(VENTILZU);
      GasEinlass(VENTILZU);
      BierEinlass(VENTILZU);
      actState = STATE_CO2FUELLEN;
      CONSOLELN(F("CO2FUELLEN"));
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print(F("CO2FUELLEN"));
    }
  }
  else if ( STATE_CO2FUELLEN == actState )
  {
    GasAuslass(VENTILZU);
    GasEinlass(VENTILAUF);
    BierEinlass(VENTILZU);
    timerGasFuellen.start();
    if ( timerGasFuellen.timeOver() )
    {
      GasAuslass(VENTILZU);
      GasEinlass(VENTILZU);
      BierEinlass(VENTILZU);
      actState = STATE_BIERFUELLEN;
    }
  }
  else if ( STATE_BIERFUELLEN == actState )
  {
    GasAuslass(VENTILAUF);
    GasEinlass(VENTILZU);
    BierEinlass(VENTILAUF);
    actState = STATE_PRUEFEVOLL;
    CONSOLELN(F("BIERFUELLEN"));
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(F("BIERFUELLEN"));    
  }
  else if ( STATE_PRUEFEVOLL == actState )
  {
    GasAuslass(VENTILAUF);
    GasEinlass(VENTILZU);
    BierEinlass(VENTILAUF);
    if ( isSensorKontakt() )
    {
      GasEinlass(VENTILZU);
      BierEinlass(VENTILZU);
      if ( 0 < fillTimes.bierRuhe )
      {
        GasAuslass(VENTILZU);
        actState = STATE_FLASCHEVOLL;
        CONSOLELN(F("FLASCHEVOLL"));
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print(F("FLASCHEVOLL"));            
      }
      else
      {
        GasAuslass(VENTILAUF);
        actState = STATE_ENDE;
        CONSOLELN(F("FLASCHEVOLL"));
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print(F("FLASCHEVOLL"));            
      }
    }
  }
  else if ( STATE_FLASCHEVOLL == actState )
  {
    GasAuslass(VENTILZU);
    GasEinlass(VENTILZU);
    BierEinlass(VENTILZU);
    timerBierRuhe.start();
    if ( timerBierRuhe.timeOver() )
    {
      GasAuslass(VENTILAUF);
      GasEinlass(VENTILZU);
      BierEinlass(VENTILZU);
      actState = STATE_ENDE;
      CONSOLELN(F("ENDE"));
    }
  }
  else if ( STATE_ENDE == actState )
  {
    restart();  
    actState = STATE_START;
    CONSOLELN(F("START"));
    lcd.clear();
  }
}
///////////////////////////////////////////////////////////////////////////////
