
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

struct cell
{
    int row;                            // sor index (0-tól, fentről lefele)
    int col;                            // oszlop index (0-tól, balról jobbra)
    int count;                          // index a táblában
    char figure;                        // ' ' vagy 'O' vagy 'X'

    XPATTERN pattern[4];                // alakzatok négy irányban: K,Ék,É,Dk
    int fieldval[2];                    // cella értrék a két játékosra: [0]='O', [1]='X'
    int valuedir[2];                    // milyen irányú a legértékesebb alakzat

    cell(int r, int c);                 // konstruktor

    cell *set();                        // felteszi magát a táblára
    void calcval();                     // kiszámítja a saját értékét
    int maxval();                       // 'X' és 'O' közül az értékesebb
    void modval();                      // újraszámolja a szomszéd cellák értékét

    // osztály adatok
    static int  init;                   // osztály adatok inicializálása 
    static cell *cells[ROWCOL];         // az összes cella tömbje (ez maga a tábla)
    static int spiral[ROWCOL];          // cellák középről kifele sorrendben
    static int movestack[ROWCOL];       // lépések
    static int movecount;               // lépésszám
    static int moveforw;                // eddig lehet előremenni (hátralépések után)
    static cell *best_move[2];          // O és X legjobb lépése
    static cell *second_move[2];        // O és X második legjobb lépése
    static char winner;                 // ' ' vagy 'O' vagy 'X'
    
    // osztály függvények
    static int classinit();             // inicializálja az osztály adatokat
    static cell *unset();               // leveszi az utolsó figurát a tábláról
    static int  posvalue();             // statikus állás kiértékelés
    static void store_best(cell*);      // tárolja a legjobb cellát

    static int  cmp_value
            (void const*,void const*);  // melyik cellában van értékesebb alakzat

    static int  cmp_dist
            (void const*,void const*);  // melyik cella van távolabb a középtől
};


#define BVAL(x)  (cell::best_move[x]?cell::best_move[x]->fieldval[x]:0)
#define BDIR(x)  (cell::best_move[x]?cell::best_move[x]->valuedir[x]:-1)
#define SVAL(x)  (cell::second_move[x]?cell::second_move[x]->fieldval[x]:0)
#define SDIR(x)  (cell::second_move[x]?cell::second_move[x]->valuedir[x]:-1)

