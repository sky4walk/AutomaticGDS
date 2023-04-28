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
#define MAXBUTTONS          6
#define PINLCD              10
#define PINKEY              0
#define PINWATER            1
#define PINGE               13  //D13
#define PINGA               12  //D12
#define PINBE               11  //D11
#define DEFGASSPUELEN       2000
#define DEFGASFUELLEN       2000
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
  int gasSpuelen;
  int gasFuellen;
  bool UseDefault;  
} fillTimes;
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
    fillTimes.UseDefault   = true;

    store.save(0, sizeof(Times), (char*)&fillTimes);
  }
  CONSOLE("gS:");
  CONSOLELN(fillTimes.gasSpuelen);
  CONSOLE("gF:");
  CONSOLELN(fillTimes.gasFuellen);
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
void setButton(int btnNr)
{
  if ( MAXBUTTONS > btnNr  && 0 != btnNr )
  {
    if ( false == btnPressed[btnNr] )
    {
      btnPressed[btnNr] = true;
      CONSOLE("b");
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
    delay(200);
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
          STATE_CO2SPUELEN == actState;
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
          lcd.print(F("Start Fuellen"));
          break;
        case 1:
          lcd.print(F("Setup"));
          break;
      }
    }
  }
}
///////////////////////////////////////////////////////////////////////////////
// restart
///////////////////////////////////////////////////////////////////////////////
void restart()
{
  actMenu = MENU_SELECT;
  actState = STATE_START;
  subMenuSelect = 0;
  digitalWrite(PINGE, LOW);
  digitalWrite(PINGA, LOW);
  digitalWrite(PINBE, LOW);
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
  printLogo();
  restart();
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
  }
}
