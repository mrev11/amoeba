
/*
 *  CCC - The Clipper to C++ Compiler
 *  Copyright (C) 2005 ComFirm BT.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */



#define MAXTABLE    24
#define MAXCELLS    MAXTABLE*MAXTABLE
#define MAXBEST     512
#define MAXLAYER    33      // egy cellalnak max 32 szomszedja lehet

#define KELET       0       // kelet
#define EKELET      1       // észak-kelet
#define ESZAK       2       // észak
#define DKELET      3       // dél-kelet


typedef unsigned long long ZCODE;  // 64 bit zobrist code 



struct XPATTERN
{
    char white[4];          // feher alakzatok negy iranyban (1 alakzat==1 byte)
    char black[4];          // fekete alakzatok negy iranyban (1 alakzat==1 byte)
};


struct FLDVAL
{
    int white;              // feher alakzatok osszpontszama
    int black;              // fekete alakzatok osszpontszama
};


struct SIBLING
{
    int cx;                 // szomszed cella indexe
    int mask;               // modosulo bit pozicioja 
    int direction;          // milyen iranyban van a szomszed
};


struct BEST
{
    int cx;                 // cella index
    int vo;                 // oppo  az ellenfel alakzatainak erteke
    int vt;                 // turn  a sajat alakzatok erteke
    int vs;                 // vo es vt osszege
};



struct cell
{
    cell(int r, int c);                 // konstruktor


    //----- objektum adatok -----

    int row;                            // sor index (0-tól, fentről lefele)
    int col;                            // oszlop index (0-tól, balról jobbra)
    int count;                          // cella index a táblában (0->MAXCELLS-1)
    char figure;                        // ' ' vagy 'O' vagy 'X'
    int layer;                          // layer index
    double dist;                        // középponttól vett távolság (perturbálva)

    char wall[4];                       // tablarol lelogo resz maszkja negy iranyban
    FLDVAL fieldval[MAXLAYER+1];        // cella érték a két játékosra retegenkent
    XPATTERN pattern[MAXLAYER+1];        // alakzatok négy irányban: K,Ék,É,Dk, retegenkent
    SIBLING siblings[MAXLAYER+1];       // szomszed cellak (max 32 lehet, az utolso utan cx=-1, mask==0)


    //----- objektum metodusok -----

    void   initsiblings();              // osszegyujti a szomszedokat, inicializalja wall-t
    int    pushlayer();                 // uj reteget tesz fel
    int    poplayer();                  // leszedi a folso reteget
    cell   *set();                      // felteszi magát a táblára
    void   updatesiblings();            // újraszámolja a szomszéd cellák értékét set() utan
    void   calcval();                   // kiszámítja a saját cella értékét
    double calcdist(int r, int c);      // [r,c]-től vett távolság (perturbálva)
    void   print();                     // debug info


    //----- osztály adatok -----

    static cell *cells[MAXCELLS];       // az összes cella tömbje (ez maga a tábla)
    static int  spiral[MAXCELLS];       // cellák középről kifele sorrendben (perturbálva)
    static int  movestack[MAXCELLS];    // stack a lépéseknek
    static int  movecount;              // lépésszám (stack pointer)
    static int  moveforw;               // eddig lehet előremenni (hátralépések után)
    static char winner;                 // ' ' vagy 'O' vagy 'X'
    static int  tablesize;              // táblaméret (default=16)

    static int  save_move[MAXCELLS];    // stack a lépéseknek
    static int  save_count;             // lépésszám (stack pointer)
    static int  save_forw;              // eddig lehet előremenni (hátralépések után)

    static char map[MAXCELLS/4+1];      // az állást tartalmazó bitmap
    static ZCODE rnd[MAXCELLS][2];      // véletlen számok a zobrist kódhoz
    static ZCODE code;                  // az állás zobrist kódja 


    //----- osztály függvények -----

    static int  classinit();            // inicializálja az osztály adatokat
    static void randomize();            // randomizálás középre
    static void randomize(int);         // randomizálás cellaindexre
    static void randomize(int,int);     // randomizálás koordinátákra
    static cell *unset();               // leveszi az utolsó figurát a tábláról
    static int  movegen(int,int);       // megkeresi a fontos lépéseket
    static int  posvalue();             // statikus állás kiértékelés
    static void print_pattern(int);     // debug info

    static void save();
    static void restore();

    static BEST best[MAXBEST];          // a movegen által kiválasztott cellák
    static int  bestcnt;                // a best-ben levő cellák darabszáma

    static int  cmp_best
            (void const*,void const*);  // melyik cellában van értékesebb alakzat

    static int  cmp_dist
            (void const*,void const*);  // melyik cella van távolabb a középtől

    static ZCODE zobrist();             // kiszámítja a zobrist kódot
    static void zobrist_update();       // kiszámítja a zobrist kódot
};



