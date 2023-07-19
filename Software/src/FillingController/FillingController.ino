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
#define MAXBUTTONS          6
#define PINLCD              10
#define PINKEY              0
#define PINWATER            1
#define PINGE               13  //1 GE
#define PINGA               12  //2 GA
#define PINBE               11  //3 BE
#define DEFGASSPUELEN       5
#define DEFGASFUELLEN       5
#define DEFBIERRUHE         10
#define DEFTOWATER          50
#define VENTILZU            false
#define VENTILAUF           true
#define TIMEADDDELTA        1
#define TOWATERADDDELTA     10
#define PRINTCONTACTVAL     500

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
  MENU_SETUP_SPUELEN,
  MENU_MANUAL,
  MENU_SETUP_FUELLEN,
  MENU_SETUP_RUHE,
  MENU_SETUP_AUSLOESE
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
int               actState = STATE_START;
int               actMenu  = MENU_SELECT;
int               subMenuSelect = 0;
bool              btnPressed[MAXBUTTONS]    = {false, false, false, false, false, false};
bool              sensorContact = false;
LiquidCrystal     lcd(8, 9, 4, 5, 6, 7);
StorageEEProm     store;
WaitTime          timerGasSpuelen;
WaitTime          timerGasFuellen;
WaitTime          timerBierRuhe;
WaitTime          timerPrintContactVal;
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
// isSensorKontakt
///////////////////////////////////////////////////////////////////////////////
bool isSensorKontakt()
{
  bool val = false;
  bool val_old = false;

  timerBierRuhe.start();
  if ( false == sensorContact )
  {
    val = isButtonPressed(BUTTON_RIGHT);
    if ( false == val)
    {
      do
      {
        val_old = val;
        int rd = analogRead(PINWATER);
        if ( timerBierRuhe.timeOver())
        {
          CONSOLE(F("tv:"));
          CONSOLELN(rd);
          timerBierRuhe.restart();
        }
        if ( fillTimes.toWater > rd )
          val = true;
        else
          val = false;
        delay(10);
      }
      while ( val != val_old );
    }
  }
  if ( val )
  {
    sensorContact = true;
    CONSOLELN(F("SensorOn"));
  }
  return sensorContact;
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
  sensorContact = false;
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
// setup
///////////////////////////////////////////////////////////////////////////////
void setup() {
  Serial.begin(115200);
  pinMode(PINLCD,         OUTPUT);
  pinMode(PINGE,          OUTPUT);
  pinMode(PINGA,          OUTPUT);
  pinMode(PINBE,          OUTPUT);
  pinMode(PINWATER,       INPUT_PULLUP);
  lcdSync();
  LoadValues();
  digitalWrite(PINLCD, HIGH);
  digitalWrite(PINGE, LOW);
  digitalWrite(PINGA, LOW);
  digitalWrite(PINBE, LOW);
  statesVentile.BierEin = false;
  statesVentile.GasAus = false;
  statesVentile.GasEin = false;
  restart();
  printLogo();
  timerGasSpuelen.setTime(fillTimes.gasSpuelen*MIL2SEC);
  timerGasFuellen.setTime(fillTimes.gasSpuelen*MIL2SEC);
  timerBierRuhe.setTime(fillTimes.bierRuhe*MIL2SEC);
  timerPrintContactVal.setTime(PRINTCONTACTVAL);
}
///////////////////////////////////////////////////////////////////////////////
// menu
///////////////////////////////////////////////////////////////////////////////
void menu()
{
  lcd.setCursor(0,0);
  if ( MENU_SELECT == actMenu )
  {
    if ( true == SubStateChange(3) )
    {
      switch ( subMenuSelect )
      {
        case 0:
          actState = STATE_CO2SPUELEN;
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print(F("CO2 Spuelen"));
          CONSOLELN(F("CO2SPUELEN"));
          break;
        case 1:
          actMenu = MENU_SETUP_SPUELEN;
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print(F("SETUP"));
          CONSOLELN(F("SETUP"));
          break;
        case 2:
          actMenu = MENU_MANUAL;
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print(F("MANUAL"));
          CONSOLELN(F("MANUAL"));
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
        case 2:
          lcd.print(F("Manual"));
          break;
      }
    }
  }
  else if ( MENU_MANUAL == actMenu )
  {
    char buffer [18];
    int rd = analogRead(PINWATER);
    sprintf (buffer, "%4u", rd);

    lcd.setCursor(0, 0);
    lcd.print(F("Manual:"));
    
    timerPrintContactVal.start();
    if ( timerPrintContactVal.timeOver() )
    {
      lcd.print(buffer);
      CONSOLE(F("M:"));
      CONSOLELN(buffer);
      timerPrintContactVal.restart();
    }        
    lcd.setCursor(0, 1);
    if ( isButtonPressed ( BUTTON_UP ) )
    {
      GasEinlass( !statesVentile.GasEin );
      if (statesVentile.GasEin) lcd.print(F("GE: ON"));
      else                      lcd.print(F("GE:OFF"));
    }
    else if ( isButtonPressed ( BUTTON_DOWN ) )
    {
      GasAuslass(!statesVentile.GasAus);
      if (statesVentile.GasAus) lcd.print(F("GA: ON"));
      else                      lcd.print(F("GA:OFF"));
    }
    else if ( isButtonPressed ( BUTTON_RIGHT ) )
    {
      BierEinlass(!statesVentile.BierEin);
      if (statesVentile.BierEin) lcd.print(F("BE: ON"));
      else                       lcd.print(F("BE:OFF"));
    }
    else if ( isButtonPressed ( BUTTON_LEFT ) )
    {
      actMenu = MENU_SELECT;
      lcd.clear();
    }  
  }
  else if ( MENU_SETUP_SPUELEN == actMenu )
  {
    lcd.print(F("CO2 Spuelzeit [s]"));
    lcd.setCursor(0, 1);
    lcd.print(fillTimes.gasSpuelen);

    if ( isButtonPressed ( BUTTON_UP ) )
      fillTimes.gasSpuelen += TIMEADDDELTA;
    else if ( isButtonPressed ( BUTTON_DOWN ) )
    {
      if ( 0 < fillTimes.gasSpuelen )
        fillTimes.gasSpuelen -= TIMEADDDELTA;
    }
    else if ( isButtonPressed ( BUTTON_LEFT ) )
    {
      actMenu = MENU_SETUP_FUELLEN;
      lcd.clear();
      CONSOLELN( fillTimes.gasSpuelen );
    }
  }
  else if ( MENU_SETUP_FUELLEN == actMenu )
  {
    lcd.print(F("CO2 Fuellzeit [s]"));
    lcd.setCursor(0, 1);
    lcd.print(fillTimes.gasFuellen);

    if ( isButtonPressed ( BUTTON_UP ) )
      fillTimes.gasFuellen += TIMEADDDELTA;
    else if ( isButtonPressed ( BUTTON_DOWN ) )
    {
      if ( 0 < fillTimes.gasFuellen )
        fillTimes.gasFuellen -= TIMEADDDELTA;
    }
    else if ( isButtonPressed ( BUTTON_LEFT ) )
    {
      actMenu = MENU_SETUP_RUHE;
      lcd.clear();
      CONSOLELN( fillTimes.gasFuellen );
    }
  }
  else if ( MENU_SETUP_RUHE == actMenu )
  {
    lcd.print(F("Bier Ruhe [s]"));
    lcd.setCursor(0, 1);
    lcd.print(fillTimes.bierRuhe);

    if ( isButtonPressed ( BUTTON_UP ) )
      fillTimes.bierRuhe += TIMEADDDELTA;
    else if ( isButtonPressed ( BUTTON_DOWN ) )
    {
      if ( 0 < fillTimes.bierRuhe )
        fillTimes.bierRuhe -= TIMEADDDELTA;
    }
    else if ( isButtonPressed ( BUTTON_LEFT ) )
    {
      actMenu = MENU_SETUP_AUSLOESE;
      lcd.clear();
      CONSOLELN( fillTimes.bierRuhe );
    }
  }
  else if ( MENU_SETUP_AUSLOESE == actMenu )
  {
    lcd.print(F("Ausloese Schwelle"));
    lcd.setCursor(0, 1);
    lcd.print(fillTimes.toWater);

    if ( isButtonPressed ( BUTTON_UP ) )
    {
      if ( 1023 > fillTimes.toWater )
        fillTimes.toWater += TOWATERADDDELTA;
    }
    else if ( isButtonPressed ( BUTTON_DOWN ) )
    {
      if ( 0 < fillTimes.toWater )
        fillTimes.toWater -= TOWATERADDDELTA;
    }
    else if ( isButtonPressed ( BUTTON_LEFT ) )
    {
      actMenu = MENU_SELECT;
      lcd.clear();
      store.save(0, sizeof(Times), (char*)&fillTimes);
      CONSOLELN( fillTimes.toWater );
    }
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
      lcd.print(F("CO2 Fuellen"));
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
    sensorContact = false;
    CONSOLELN(F("Bier Fuellen"));
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(F("Bier Fuellen"));    
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
        lcd.print(F("Bier Ruhe"));            
      }
      else
      {
        GasAuslass(VENTILAUF);
        actState = STATE_ENDE;
        CONSOLELN(F("FLASCHEVOLL"));
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print(F("Flasche Voll"));            
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
      CONSOLELN(F("Ende"));
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
