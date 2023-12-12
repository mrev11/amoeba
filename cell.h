
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
#define MAXBEST     64


struct BEST
{
    int cx;
    int vo;    // oppo
    int vt;    // turn
    int vs;    // sum
};


struct cell
{
    int row;                            // sor index (0-tól, fentről lefele)
    int col;                            // oszlop index (0-tól, balról jobbra)
    int count;                          // index a táblában
    char figure;                        // ' ' vagy 'O' vagy 'X'
    double dist;                        // középpontól vett távolság (perturbálva)

    XPATTERN pattern[4];                // alakzatok négy irányban: K,Ék,É,Dk
    int fieldval[2];                    // cella értrék a két játékosra: [0]='O', [1]='X'
    int valuedir[2];                    // milyen irányú a legértékesebb alakzat

    cell(int r, int c);                 // konstruktor

    double calcdist(int r, int c);      // [r,c]-től vett távolság (perturbálva)
    cell   *set();                      // felteszi magát a táblára
    void   calcval();                   // kiszámítja a saját értékét
    void   modval();                    // újraszámolja a szomszéd cellák értékét

    // osztály adatok
    static int  init;                   // osztály adatok inicializálása 
    static cell *cells[MAXCELLS];       // az összes cella tömbje (ez maga a tábla)
    static int  spiral[MAXCELLS];       // cellák középről kifele sorrendben (perturbálva)
    static int  movestack[MAXCELLS];    // stack a lépéseknek
    static int  movecount;              // lépésszám (stack pointer)
    static int  moveforw;               // eddig lehet előremenni (hátralépések után)
    static char winner;                 // ' ' vagy 'O' vagy 'X'
    static int  tablesize;              // táblaméret (default=16)
    
    // osztály függvények
    static int  classinit();            // inicializálja az osztály adatokat
    static void randomize(int,int);     // randomizálás 
    static cell *unset();               // leveszi az utolsó figurát a tábláról
    static int  movegen(int);           // megkeresi a fontos lépéseket
    static int  movegen1(int);          // megkeresi a fontos lépéseket (alternatív)
    static int  posvalue();             // statikus állás kiértékelés

    static BEST best[MAXBEST];          // a movegen által kiválasztott cellák
    static int  bestcnt;                // a best-ben levő cellák darabszáma

    static int  cmp_best
            (void const*,void const*);  // melyik cellában van értékesebb alakzat

    static int  cmp_dist
            (void const*,void const*);  // melyik cella van távolabb a középtől
};



