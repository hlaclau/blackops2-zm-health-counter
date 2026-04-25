#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\gametypes_zm\spawnlogic;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\gametypes_zm\_hud_message;

init()
{
    level endon( "end_game" );

    // ── Layout constants ──────────────────────────────────────────
    level.HUD_ANCHOR_Y      = 20;
    level.ROW_HEALTH        = 0;
    level.ROW_ZOMBIES_ALIVE = 28;
    level.ROW_ZOMBIES_TOTAL = 52;

    // ── Font ──────────────────────────────────────────────────────
    level.FONT_LABEL  = "Objective";
    level.FONT_VALUE  = "small";
    level.FONT_SZ_LBL = 1.4;
    level.FONT_SZ_VAL = 1.4;

    // ── Health thresholds ─────────────────────────────────────────
    level.HP_HIGH = 170;
    level.HP_MED  = 130;
    level.HP_LOW  = 80;

    // ── Zombie thresholds ─────────────────────────────────────────
    level.ZA_HIGH = 18;
    level.ZA_MED  = 12;
    level.ZT_WARN = 50;

    // ── Catppuccin Mocha colors ───────────────────────────────────
    level.CLR_MAUVE    = (0.796, 0.651, 0.969);
    level.CLR_LAVENDER = (0.706, 0.745, 0.996);
    level.CLR_PINK     = (0.953, 0.545, 0.659);
    level.CLR_MAROON   = (0.922, 0.627, 0.675);
    level.CLR_PEACH    = (0.980, 0.702, 0.529);
    level.CLR_GREEN    = (0.651, 0.890, 0.631);
    level.CLR_YELLOW   = (0.976, 0.886, 0.686);
    level.CLR_SUBTEXT  = (0.651, 0.678, 0.784);

    // ── Pulse speed ───────────────────────────────────────────────
    level.PULSE_RATE = 0.35;

    level thread onplayerconnect();
}

onplayerconnect()
{
    for ( ;; )
    {
        level waittill( "connected", player );
        player thread onplayerspawn();
        player thread HUD_Health();
        player thread HUD_ZombiesAlive();
        player thread HUD_ZombiesTotal();
        player thread HUD_CriticalPulse();
    }
}

onplayerspawn()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    self.zombiesvisible = true;
    for ( ;; )
        self waittill( "spawned_player" );
}

// ─── ROW 1 : HEALTH  ( HP  cur / max ) ──────────────────────────────────────

HUD_Health()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    flag_wait( "initial_blackscreen_passed" );

    self._lbl_hp = createFontString( level.FONT_LABEL, level.FONT_SZ_LBL );
    self._lbl_hp setpoint( "TOPRIGHT", "TOPRIGHT", -115, level.HUD_ANCHOR_Y + level.ROW_HEALTH );
    self._lbl_hp setText( "HP" );
    self._lbl_hp.color = level.CLR_SUBTEXT;
    self._lbl_hp.alpha = 1;

    self._val_hp = createFontString( level.FONT_VALUE, level.FONT_SZ_VAL );
    self._val_hp setpoint( "TOPRIGHT", "TOPRIGHT", -85, level.HUD_ANCHOR_Y + level.ROW_HEALTH );
    self._val_hp.label = &"";
    self._val_hp.alpha = 1;

    self._slash = createFontString( level.FONT_VALUE, level.FONT_SZ_VAL );
    self._slash setpoint( "TOPRIGHT", "TOPRIGHT", -58, level.HUD_ANCHOR_Y + level.ROW_HEALTH );
    self._slash setText( "/" );
    self._slash.color = level.CLR_SUBTEXT;
    self._slash.alpha = 1;

    self._val_hp_max = createFontString( level.FONT_VALUE, level.FONT_SZ_VAL );
    self._val_hp_max setpoint( "TOPRIGHT", "TOPRIGHT", -28, level.HUD_ANCHOR_Y + level.ROW_HEALTH );
    self._val_hp_max.label = &"";
    self._val_hp_max.alpha = 1;

    while ( true )
    {
        hp    = self.health;
        maxhp = self.maxhealth;

        if      ( hp > level.HP_HIGH ) self._val_hp.color = level.CLR_MAUVE;
        else if ( hp > level.HP_MED  ) self._val_hp.color = level.CLR_LAVENDER;
        else if ( hp > level.HP_LOW  ) self._val_hp.color = level.CLR_PINK;
        else                           self._val_hp.color = level.CLR_MAROON;

        if ( maxhp >= 250 )
            self._val_hp_max.color = level.CLR_MAUVE;
        else
            self._val_hp_max.color = level.CLR_PEACH;

        self._val_hp     setvalue( hp );
        self._val_hp_max setvalue( maxhp );
        wait 0.05;
    }
}

// ─── CRITICAL HEALTH PULSE ───────────────────────────────────────────────────

HUD_CriticalPulse()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    flag_wait( "initial_blackscreen_passed" );

    while ( true )
    {
        if ( self.health <= level.HP_LOW )
        {
            self._val_hp.alpha = 1.0;
            wait level.PULSE_RATE;
            self._val_hp.alpha = 0.30;
            wait level.PULSE_RATE;
        }
        else
        {
            self._val_hp.alpha = 1.0;
            wait 0.1;
        }
    }
}

// ─── ROW 2 : ZOMBIES ALIVE ───────────────────────────────────────────────────

HUD_ZombiesAlive()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    flag_wait( "initial_blackscreen_passed" );

    self._lbl_za = createFontString( level.FONT_LABEL, level.FONT_SZ_LBL );
    self._lbl_za setpoint( "TOPRIGHT", "TOPRIGHT", -115, level.HUD_ANCHOR_Y + level.ROW_ZOMBIES_ALIVE );
    self._lbl_za setText( "Alive" );
    self._lbl_za.color = level.CLR_SUBTEXT;
    self._lbl_za.alpha = 1;

    self._val_za = createFontString( level.FONT_VALUE, level.FONT_SZ_VAL );
    self._val_za setpoint( "TOPRIGHT", "TOPRIGHT", -28, level.HUD_ANCHOR_Y + level.ROW_ZOMBIES_ALIVE );
    self._val_za.label = &"";
    self._val_za.alpha = 1;

    while ( true )
    {
        alive = get_current_zombie_count();

        if      ( alive > level.ZA_HIGH ) self._val_za.color = level.CLR_PINK;
        else if ( alive > level.ZA_MED  ) self._val_za.color = level.CLR_YELLOW;
        else                              self._val_za.color = level.CLR_GREEN;

        self._val_za setvalue( alive );
        wait 0.05;
    }
}

// ─── ROW 3 : ZOMBIES REMAINING ───────────────────────────────────────────────

HUD_ZombiesTotal()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    flag_wait( "initial_blackscreen_passed" );

    self._lbl_zt = createFontString( level.FONT_LABEL, level.FONT_SZ_LBL );
    self._lbl_zt setpoint( "TOPRIGHT", "TOPRIGHT", -115, level.HUD_ANCHOR_Y + level.ROW_ZOMBIES_TOTAL );
    self._lbl_zt setText( "Left" );
    self._lbl_zt.color = level.CLR_SUBTEXT;
    self._lbl_zt.alpha = 1;

    self._val_zt = createFontString( level.FONT_VALUE, level.FONT_SZ_VAL );
    self._val_zt setpoint( "TOPRIGHT", "TOPRIGHT", -28, level.HUD_ANCHOR_Y + level.ROW_ZOMBIES_TOTAL );
    self._val_zt.label = &"";
    self._val_zt.alpha = 1;

    while ( true )
    {
        total = level.zombie_total + get_current_zombie_count();

        if ( total > level.ZT_WARN )
            self._val_zt.color = level.CLR_PINK;
        else
            self._val_zt.color = level.CLR_GREEN;

        self._val_zt setvalue( total );
        wait 0.05;
    }
}
