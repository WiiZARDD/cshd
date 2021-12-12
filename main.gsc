#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/_hud_message;

init() {
    PreCacheShader("gradient_center");
    level thread onPlayerConnect();
}

onPlayerConnect() {
    for (;;) {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned() {
    self endon("disconnect");
    level endon("game_ended");
    for (;;) {
        self waittill("spawned_player");
        self thread Mapname();
        if (self isHost()) {
            self thread destroyElemOnDeath();
            self thread RunControl();
        }
    }
}

RunControl() {
    self addMenu("Main", 0, "GameModes", ::NewMenu, "FunMenu");
    self addMenu("Main", 1, "Edit ^1Self", ::NewMenu, "EDP");
    self addMenu("Main", 2, "Advertise", ::NewMenu, "Adv");
    self addMenu("Main", 3, "VIP Menu", ::NewMenu, "VIPM");
    self addMenu("Main", 4, "Admin Menu", ::NewMenu, "ADM");
    self addMenu("Main", 5, "Host Menu", ::NewMenu, "HMM");
    self addMenu("Main", 6, "Lobby Menu", ::NewMenu, "EDMenu");

    self addOpt("FunMenu", 0, "Sub Item 1", ::Test);
    self addOpt("FunMenu", 1, "Sub Item 2", ::Test);

    self addOpt("VIPM", 0, "Cranked", ::Test);
    self addOpt("VIPM", 1, "AON", ::Test);

    self addMenu("ADM", 0, "Aimbot Menu", ::NewMenu, "Aim");
    self addOpt("ADM", 1, "Explosive Bullets", ::Test);

    self addOpt("Aim", 0, "Legit Aimbot", ::autoAim);
    self addOpt("Aim", 1, "Unfair Aimbot", ::Test);

    self addMenu("Adv", 0, "Welcome", ::NewMenu, "Adv");
    self addMenu("Adv", 1, "Host", ::NewMenu, "Adv");
    self addOpt("Adv", 2, "Kill Text", ::Test);
    self addMenu("Adv", 3, "Host1", ::NewMenu, "Adv");
    self addMenu("Adv", 4, "More Advertisements", ::NewMenu, "Adv2");

    self addOpt("Adv2", 0, "Host DoHeart", ::doHeart);
    self addOpt("Adv2", 1, "Menu DoHeart", ::Test);

    self addOpt("EDP", 0, "Godmode", ::toggle_god);
    self addOpt("EDP", 1, "Unlimited Ammo", ::InfiniteAmmo);
    self addOpt("EDP", 2, "No Clip", ::UFOMode);
    self addOpt("EDP", 3, "UAV", ::ToggleUAV);
    self addOpt("EDP", 4, "Redbox", ::toggleThermal);
    self addOpt("EDP", 5, "suicide Bomber", ::suicideBomb);
    self addOpt("EDP", 6, "Messed Up Clone", ::deadclone);
    self addOpt("EDP", 7, "Edit XYZ Positioning", ::xyzEditor);

    self addOpt("EDMenu", 0, "Multi Jump", ::Test);
    self addOpt("EDMenu", 1, "Left Gun", ::ToggleLeft);
    self addOpt("EDMenu", 2, "Unlimited Game", ::Inf_Game);
    self addOpt("EDMenu", 3, "Fast Restart", ::doRestart);
    self addMenu("EDMenu", 4, "Bots Menu", ::NewMenu, "BMenu");
    
    self addOpt( "BMenu", 0, "Spawn x1 Bot", ::Bots1, "" );
    self addOpt( "BMenu", 1, "Spawn x3 Bot", ::Bots3, "" );
    self addOpt( "BMenu", 2, "Spawn x5 Bot", ::Bots5, "" );
    self addOpt( "BMenu", 3, "Bots Move", ::funcBotsMove, "" );
    self addOpt( "BMenu", 4, "Bots Play", ::funcBotsAttack, "" );
    
    self addOpt("HMM", 0, "Force Host", ::forceHost);

    self.SCL = 0;
    self.MenuInUse = false;
    for (;;) {
        if (self.MenuInUse == false) {
            if (self meleeButtonPressed()) {

                self.Menu[1] = self createRectangle("CENTER", "CENTER", 0, 0, 0, 0, (0, 0, 0), "gradient_center", 1, 0);
                self.Menu[2] = self createRectangle("CENTER", "CENTER", 0, 0, 0, 0, (0, 0.9, 0.5), "gradient_center", 2, 0);
                NewMenu("Main");
                self setblurforplayer(8, .5);
                self freezeControls(true);
                self.MenuInUse = true;
            }
        } else {
            if (self adsButtonPressed() || self attackButtonPressed()) {
                if (self adsButtonPressed()) self.SCL--;
                if (self attackButtonPressed()) self.SCL++;
                if (self.SCL < 0) self.SCL = self.MenuText[self.MenuRoot].size - 1;
                if (self.SCL > self.MenuText[self.MenuRoot].size - 1) self.SCL = 0;
                if (self.MenuSub == false) {
                    self.Menu[2] Entity(.2, self.Menu[0][self.SCL].x, undefined);
                } else {
                    self.Menu[2] Entity(.2, undefined, self.Menu[0][self.SCL].y);
                }
                wait .2;
            }
            if (self MeleeButtonPressed()) {
                if (self.MenuRoot != "Main") {
                    self.MenuSub = false;
                    NewMenu("Main");
                } else {
                    for (x = 0; x < 20; x++) self.Menu[0][x] Entity(.5, undefined, undefined, 0);
                    self.Menu[1] Entity(.5, undefined, undefined, 0);
                    self.Menu[2] Entity(.5, undefined, undefined, 0);
                    wait .5;
                    for (x = 0; x < 20; x++) self.Menu[0][x] Destroy();
                    self.Menu[1] Destroy();
                    self.Menu[2] Destroy();
                    self.MenuInUse = false;
                    self setblurforplayer(0, 0.5);
                    self freezeControls(false);
                }
            }
            if (self UseButtonPressed()) {
                self thread[[self.MenuFunc[self.MenuRoot][self.SCL]]](self.MenuArg1[self.MenuRoot][self.SCL], self.MenuArg2[self.MenuRoot][self.SCL], self.MenuArg3[self.MenuRoot][self.SCL]);
                wait 0.4;
            }
        }
        if (self.MenuRoot == "Main") self.MenuSub = false;
        else self.MenuSub = true;
        wait .1;
    }
}

NewMenu(Menu) {
    self.SCL = 0;
    self.MenuRoot = Menu;
    for (x = 0; x < 20; x++) self.Menu[0][x] Entity(.5, undefined, undefined, 0);
    wait .4;
    for (x = 0; x < 20; x++) self.Menu[0][x] Destroy();
    if (self.MenuSub == false) {
        self thread TextBuild(Menu, 1);
        self.Menu[1] Entity(.5, 0, -225, 0.5, "f", 1000, 30);
        self.Menu[2] Entity(.5, self.Menu[0][self.SCL].x, -225, 0.3, "f", 105, 22);
        wait .4;
        for (x = 0; x < 20; x++) self.Menu[0][x] Entity(.5, undefined, undefined, 1);
    } else {
        self thread TextBuild(Menu, 1);
        self.Menu[1] Entity(.5, 0, 0, 0.5, "f", 400, 1000);
        self.Menu[2] Entity(.5, 0, self.Menu[0][self.SCL].y, 0.8, "f", 400, 25);
        wait .4;
        for (x = 0; x < 20; x++) self.Menu[0][x] Entity(.5, undefined, undefined, 1);
    }
}

TextBuild(Menu, Alpha) {
    self.MenuRoot = Menu;
    for (i = 0; i < self.MenuText[Menu].size; i++) {
        if (self.MenuSub == false) {
            self.Menu[0][i] = self createfontstring("default", 1.6);
            self.Menu[0][i] setpoint("CENTER", "CENTER", -280 + (i * 110), -226);
            self.Menu[0][i] settext(self.MenuText[Menu][i]);
            self.Menu[0][i].alpha = Alpha;
        } else {
            self.Menu[0][i] = self createfontstring("default", 1.6);
            self.Menu[0][i] setpoint("CENTER", "CENTER", 0, -150 + (i * 25));
            self.Menu[0][i] settext(self.MenuText[Menu][i]);
            self.Menu[0][i].alpha = Alpha;
        }
    }
}

addMenu(Menu, Num, Text, Func, Arg1, Arg2, Arg3) {
    self.MenuText[Menu][Num] = Text;
    self.MenuFunc[Menu][Num] = Func;
    if (isDefined(Arg1)) {
        self.MenuArg1[Menu][Num] = Arg1;
        self.MenuArg2[Menu][Num] = Arg2;
        self.MenuArg3[Menu][Num] = Arg3;
    }
}
addOpt(Menu, Num, Text, Func) {
    self.MenuText[Menu][Num] = Text;
    self.MenuFunc[Menu][Num] = Func;
}

Entity(Time, X, Y, Alpha, force, width, height) {
    if (!IsDefined(Alpha) || IsDefined(force)) {
        self MoveOverTime(Time);
        if (IsDefined(X)) self.x = X;
        if (IsDefined(Y)) self.y = Y;
    }
    if (IsDefined(Alpha)) {
        self FadeOverTime(Time);
        self.alpha = Alpha;
    }
    if (IsDefined(width)) self ScaleOverTime(Time, width, height);
}

Bots1()
{
    self thread initTestClients(1);
}
Bots3()
{
    self thread initTestClients(3);
}
Bots5()
{
    self thread initTestClients(5);
}
initTestClients(value)
{
    for(i = 0; i < value; i++)
    {
        ent[i] = addtestclient();
        if (!isdefined(ent[i]))
        {
            wait 1;
            continue;
        }
        ent[i].pers["isBot"] = true;
        ent[i] thread initIndividualBot();
        wait 0.1;
    }
} 

initIndividualBot()
{
    self endon( "disconnect" );
    while(!isdefined(self.pers["team"]))
        wait .05;
    self notify("menuresponse", game["menu_team"], "autoassign");
    wait 0.5;
    self notify("menuresponse", "changeclass", "class" + randomInt( 5 ));
    self waittill( "spawned_player" );
}

Fox() {
    self thread toggle_god();
}

toggle_god() {
    if (self.godmode == false) {
        self EnableInvulnerability();
        self.godmode = true;
        self drawHudMsg("God Mode [^2On^7]");
    } else if (self.godmode == true) {
        self DisableInvulnerability();
        self.godmode = false;
        self drawHudMsg("God Mode [^1Off^7]");
    }
}

WelcomeMessage(text, text1, icon) {
    hmb = spawnstruct();
    hmb.titleText = text;
    hmb.notifyText = text1;
    hmb.iconName = icon;
    hmb.hideWhenInMenu = true;
    hmb.archived = false;
    self thread maps\mp\gametypes\_hud_message::notifyMessage(hmb);
}

Mapname() {
    self thread drawHudMsg("Welcome [" + self.name + "]");
    wait 3;
    self thread drawHudMsg("[CA$HED V2]");
    wait 3;
    self thread drawHudMsg("Developed By [WiiZARD]");
}

deadclone() {
    self iprintln("Dead Clone ^2Spawned.");
    ffdc = self ClonePlayer(9999);
    ffdc startragdoll(1);
}

suicideBomb() {
    self endon("disconnect");
    self endon("stopsuicideBomb");
    self endon("death");

    self drawHudMsg("Press [{+attack}] to explode");
    self takeAllWeapons();
    self _giveWeapon("c4_mp");
    self SetWeaponAmmoStock("c4_mp", 0);
    self switchToWeapon("c4_mp");

    for (;;) {
        if (self attackbuttonpressed()) {
            wait 0.7;
            PlayFX(level._effect["torch"], self.origin + (0, 0, 60));
            RadiusDamage(self.origin, 300, 300, 200, self);
            self notify("stopsuicideBomb");
        }
        wait 0.01;
    }
}


Test() {
    self thread drawHudMsg("Test");
}

drawHudMsg(String1) {
    Text1 = self createFontString("default", 2.5);
    Text1 setPoint("RIGHT", "RIGHT", -20, 0);
    Text1 setText(String1);
    Text1.glow = 1;
    Text1.glowColor = (0, 0, 0);
    Text1.glowAlpha = 1;
    Text1.color = (1, 1, 1);
    Text1.alpha = 1;
    Text1 moveOverTime(1.3);
    Text1.y = 0;
    Text1.x = -325;
    Text1 moveOverTime(1.3);
    Text1.y = 0;
    Text1.x = 0;
    wait 1.5;
    Text1 FadeOverTime(0.9);
    wait 1.3;
    Text1 destroy();
}

InfiniteAmmo() {
    self endon("disconnect");
    self endon("disableInfAmmo");
    self thread drawHudMsg("Infinite Ammo");
    if (self.InfiniteAmmo) {
        for (;;) {
            if (self getCurrentWeapon() != "none") {
                self setWeaponAmmoClip(self getCurrentWeapon(), weaponClipSize(self getCurrentWeapon()));
                self giveMaxAmmo(self getCurrentWeapon());
            }
            if (self getCurrentOffHand() != "none")
                self giveMaxAmmo(self getCurrentOffHand());

            wait 0.05;
        }
    } else
        self notify("disableInfAmmo");
}

ToggleLeft() {
    if (self.LG == true) {
        self drawHudMsg("Left Sided Gun: [^2ON^7]");
        setDvar("cg_gun_x", "7");
        self.LG = false;
    } else {
        self drawHudMsg("Left Sided Gun: [^1OFF^7]");
        setDvar("cg_gun_x", "0");
        self.LG = true;
    }
}

toggleAim()
{
    self endon("death");
    if(self.aimtog==0)
    {
        self.aimtog=1;
        self thread autoaim();
    }
    else
    {
        self.aimtog=0;
        self thread AimStop();
    }
}
AimStop()
{
    if(self.IsAdmin)
    {
        self iPrintln("^1Aimbot OFF");
        self notify("EAA");
    }
}
autoAim()
{
    self endon("death");
    self endon("disconnect");
    self endon("EAA");
    lo=-1;
    self.fire=0;
    self thread WSh();
    self iPrintln("^2Aimbot ON");
    self.ABo="j_mainroot";
    for(;;)
    {
        wait 0.05;
        if(self AdsButtonPressed())
        {
            for(i=0;i<level.players.size;i++)
            {
                if(getdvar("g_gametype")!="dm")
                {
                    if(closer(self.origin,level.players[i].origin,lo)==true&&level.players[i].team!=self.team&&IsAlive(level.players[i])&&level.players[i]!=self&&bulletTracePassed(self getTagOrigin("j_head"),level.players[i] getTagOrigin(self.ABo),0,self))lo=level.players[i] gettagorigin(self.ABo);
                    else if(closer(self.origin,level.players[i].origin,lo)==true&&level.players[i].team!=self.team&&IsAlive(level.players[i])&&level.players[i] getcurrentweapon()=="riotshield_mp"&&level.players[i]!=self&&bulletTracePassed(self getTagOrigin("j_head"),level.players[i] getTagOrigin(self.ABo),0,self))lo=level.players[i] gettagorigin("j_ankle_ri");
                }
                else
                {
                    if(closer(self.origin,level.players[i].origin,lo)==true&&IsAlive(level.players[i])&&level.players[i]!=self&&bulletTracePassed(self getTagOrigin("j_head"),level.players[i] getTagOrigin(self.ABo),0,self))lo=level.players[i] gettagorigin(self.ABo);
                    else if(closer(self.origin,level.players[i].origin,lo)==true&&IsAlive(level.players[i])&&level.players[i] getcurrentweapon()=="riotshield_mp"&&level.players[i]!=self&&bulletTracePassed(self getTagOrigin("j_head"),level.players[i] getTagOrigin(self.ABo),0,self))lo=level.players[i] gettagorigin("j_ankle_ri");
                }
            }
            if(lo!=-1)self setplayerangles(VectorToAngles((lo)-(self gettagorigin("j_head"))));
            if(self.fire==1)MagicBullet(self getcurrentweapon(),lo+(0,0,5),lo,self);
        }
        lo=-1;
    }
}
toggleUnfairAim()
{
    self endon("death");
    if(self.aimutog==0)
    {
        self.aimutog=1;
        self thread autoUnfairAim();
    }
    else
    {
        self.aimutog=0;
        self thread AimUnfairStop();
    }
}
AimUnfairStop()
{
    if(self.IsAdmin)
    {
        self iPrintln("^1Aimbot OFF");
        self notify("EAA");
    }
}
autoUnfairAim() 
{ 
        self endon( "death" ); 
        self endon( "disconnect" ); 
        self endon("EAA");
        for(;;)  
        { 
                wait 0.01; 
                aimAt = undefined; 
                foreach(player in level.players) 
                { 
                        if( (player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || ( !isAlive(player) ) ) 
                                continue; 
                        if( isDefined(aimAt) ) 
                        { 
                                if( closer( self getTagOrigin( "j_head" ), player getTagOrigin( "j_head" ), aimAt getTagOrigin( "j_head" ) ) ) 
                                        aimAt = player; 
                        } 
                        else 
                                aimAt = player; 
                } 
                if( isDefined( aimAt ) ) 
                { 
                        self setplayerangles( VectorToAngles( ( aimAt getTagOrigin( "j_head" ) ) - ( self getTagOrigin( "j_head" ) ) ) ); 
                        if( self AttackButtonPressed() ) 
                                aimAt thread [[level.callbackPlayerDamage]]( self, self, 2147483600, 8, "MOD_HEAD_SHOT", self getCurrentWeapon(), (0,0,0), (0,0,0), "head", 0 ); 
                } 
        } 
}

toggleThermal()
{
self notifyOnPlayerCommand( "up", "+actionslot 1" );
for(;;)
    {
self waittill("up");
self ThermalVisionFOFOverlayOn();
self waittill("up");
self ThermalVisionFOFOverlayOff();
        }
}           
                    
PulsingText()
{
        self.dhtext = self createFontString( "objective", 2.5);
        self.dhtext setPoint( "TOP", "RIGHT", -50, -100 );
        self.dhtext.alpha = 1;
        self.dhtext.foreground = true;
        self.dhtext.archived = false;
        //self thread scale();
        for(;;)
        {
            self.dhtext ChangeFontScaleOverTime(0.3);
            self.dhtext.fontScale = 2.0;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext ChangeFontScaleOverTime(0.3);
            self.dhtext.fontScale = 4.0;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext ChangeFontScaleOverTime(0.3);
            self.dhtext.fontScale = 2.0;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext ChangeFontScaleOverTime(0.3);
            self.dhtext.fontScale = 4.0;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext ChangeFontScaleOverTime(0.3);
            self.dhtext.fontScale = 2.0;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext ChangeFontScaleOverTime(0.3);
            self.dhtext.fontScale = 4.0;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext ChangeFontScaleOverTime(0.3);
            self.dhtext.fontScale = 2.0;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext setText("TEXT HERE");
            wait 0.3;
            self.dhtext ChangeFontScaleOverTime(0.3);
            self.dhtext.fontScale = 4.0;
            wait 0.3;
        }
}
    
UFOMode() {
    if (self.UFOMode == false) {
        self thread doUFOMode();
        self.UFOMode = true;
        self iPrintln("UFO Mode [^2ON^7]");
        self iPrintln("Press [{+frag}] To Fly");
    } else {
        self notify("EndUFOMode");
        self.UFOMode = false;
        self iPrintln("UFO Mode [^1OFF^7]");
    }
}

doUFOMode() {
    self endon("EndUFOMode");
    self.Fly = 0;
    UFO = spawn("script_model", self.origin);
    for (;;) {
        if (self FragButtonPressed()) {
            self playerLinkTo(UFO);
            self.Fly = 1;
        } else {
            self unlink();
            self.Fly = 0;
        }
        if (self.Fly == 1) {
            Fly = self.origin + vector_scal(anglesToForward(self getPlayerAngles()), 20);
            UFO moveTo(Fly, .01);
        }
        wait .001;
    }
}

ToggleUAV()
{
if(self.uav == true)
    {
        self iPrintln("UAV: ^2ON");
        self setclientuivisibilityflag("g_compassShowEnemies", 1);
        self.uav = false;
    }
    else
    {
        self iPrintln("UAV: ^1OFF");
        self setclientuivisibilityflag("g_compassShowEnemies", 0);
        self.uav = true;
    }
}

Inf_Game()
{
    if(self.ingame==false)
    {
    self.ingame=true;
    setDvar("scr_dom_scorelimit",0);
    setDvar("scr_sd_numlives",0);
    setDvar("scr_war_timelimit",0);
    setDvar("scr_game_onlyheadshots",0);
    setDvar("scr_war_scorelimit",0);
    setDvar("scr_player_forcerespawn",1);
    maps\mp\gametypes\_globallogic_utils::pausetimer();
    self iPrintln("Unlimited Game [^2ON^7]");
    }
    else
    {
    self maps\mp\gametypes\_globallogic_utils::resumetimer();
    self iPrintln("Unlimited Game [^1OFF^7]");
    }
}

doRestart()
{
    map_restart(false);
}

doHeart()
{
    if(!isDefined(level.SA))
    {
        level.SA           = level createServerFontString("hudbig",2.1);        
        level.SA.alignX    = "right";
        level.SA.horzAlign = "right";
        level.SA.vertAlign = "middle";
        level.SA.x         = 30;
        level.SA setText("CA$HED V2");
        level.SA.archived       = false;
        level.SA.hideWhenInMenu = true;
        for (;;)
        {
            level.SA.glowAlpha = 1;
            level.SA.glowColor = ((randomint(255)/255),(randomint(255)/255),(randomint(255)/255));
            level.SA SetPulseFX(40,2000,600);
            wait 1;
        }
    }
    if(level.doheart==0)
    {
        self iPrintln("Flash Menu Name: On");
        level.doheart  = 1;
        level.SA.alpha = 1;
    }
    else if(level.doheart==1)
    {
        self iPrintln("Flash Menu Name: Off");
        level.SA.alpha = 0;
        level.doheart  = 0;
    }
}

doAmmo()
{
self endon ( "disconnect" );
self endon ( "death" );
while ( 1 ) {
currentWeapon = self getCurrentWeapon();
if ( currentWeapon != "none" ) {
self setWeaponAmmoClip( currentWeapon, 9999 );
self GiveMaxAmmo( currentWeapon );
}
currentoffhand = self GetCurrentOffhand();
if ( currentoffhand != "none" ) {
self setWeaponAmmoClip( currentoffhand, 9999 );
self GiveMaxAmmo( currentoffhand );
}
wait .05;
}
}

vector_scal(vec, scale) {
    vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
    return vec;
}

/////////////
//*Lobby* //
///////////

funcBotsAttack()
{
    if (level.BotsAttack)
    {
        level.BotsAttack = false;
        setDvar("testClients_doAttack", 0);
        self iPrintln( "^3Bots will not Attack" ); 
    }
    else
    {
        level.BotsAttack = true;
        setDvar("testClients_doAttack", 1);
        self iPrintln( "^3Bots will Attack" );
    }
}

funcBotsMove()
{
    if (level.BotsMove)
    {
        level.BotsMove = false;
        setDvar("testClients_doMove", 0);
        self iPrintln( "^3Bots will not Move" ); 
    }
    else
    {
        level.BotsMove = true;
        setDvar("testClients_doMove", 1);
        self iPrintln( "^3Bots will Move" );
    }
}


NO() {
    self thread drawHudMsg("Wut.");
}

destroyElemOnDeath() {
    self waittill("death");
    if (self.MenuRoot != "Main") {
        for (x = 0; x < 20; x++) self.Menu[0][x] Entity(.5, undefined, undefined, 0);
        self.Menu[1] Entity(.5, undefined, undefined, 0);
        self.Menu[2] Entity(.5, undefined, undefined, 0);
        wait .5;
        for (x = 0; x < 20; x++) self.Menu[0][x] Destroy();
        self.Menu[1] Destroy();
        self.Menu[2] Destroy();
        self.SCL = 0;
        self.MenuInUse = false;
        self setblurforplayer(0, .5);
        self freezeControls(false);
    }
}

isRealistic(nerd) {
self.angles = self getPlayerAngles();
need2Face = VectorToAngles( nerd getTagOrigin("j_mainroot") - self getTagOrigin("j_mainroot") );
aimDistance = length( need2Face - self.angles );
if(aimDistance < 25)
return true;
else
return false;
}
 
 
//The aimbot
doDaAim() {
self endon("disconnect");
self endon("death");
self endon("EndAutoAim");
for(;;)
{
self waittill( "weapon_fired");
abc=0;
foreach(player in level.players) {
if(isRealistic(player))
{
if(self.pers["team"] != player.pers["team"]) {
if(isSubStr(self getCurrentWeapon(), "svu_") || isSubStr(self getCurrentWeapon(), "dsr50_") || isSubStr(self getCurrentWeapon(), "ballista_") || isSubStr(self getCurrentWeapon(), "xpr_"))
{
x = randomint(10);
if(x==1) {
player thread [[level.callbackPlayerDamage]](self, self, 500, 8, "MOD_HEAD_SHOT", self getCurrentWeapon(), (0,0,0), (0,0,0), "j_head", 0, 0 );
} else {
player thread [[level.callbackPlayerDamage]](self, self, 500, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0,0,0), (0,0,0), "j_mainroot", 0, 0 );
}
}
}
}
if(isAlive(player) && player.pers["team"] == "axis") {
abc++;
}
}
if(abc==0) {
self notify("last_killed");
}
}
}

ViewM() {
    self setViewModel("veh_t6_drone_hunterkiller");
    self thread drawHudMsg("View Model Changed!");
}

CamoChanger()
{
    rand=RandomIntRange(1,45);
    weap=self getCurrentWeapon();
    self takeWeapon(weap);
    self giveWeapon(weap,0,true(rand,0,0,0,0));
    self switchToWeapon(weap);
    self giveMaxAmmo(weap);
    self iPrintln("Random Camo Received ^2#"+ rand);
}

ViewMP7() {
    self setViewModel("mp_mp7");
    self thread drawHudMsg("View Model Changed!");
}

NH() {
    self setViewModel("viewmodel_hands_no_model");
    self thread drawHudMsg("Look Mum, No Hands!");
}

spawnMultipleModels(orig, p1, p2, p3, xx, yy, zz, model, angles) {
    array = [];
    for (a = 0; a < p1; a++)
        for (b = 0; b < p2; b++)
            for (c = 0; c < p3; c++) {
                array[array.size] = spawnSM((orig[0] + (a * xx), orig[1] + (b * yy), orig[2] + (c * zz)), model, angles);
                wait .05;
            }
    return array;
}

spawnSM(origin, model, angles) {
    ent = spawn("script_model", origin);
    ent setModel(model);
    if (isDefined(angles)) ent.angles = angles;
    return ent;
}

array_Delete(array) {
    for (i = 0; i < array.size; i++) {
        array[i] delete();
    }
}