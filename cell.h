

struct cell
{
    int row;                        // sor index (0-tól, fentről lefele)
    int col;                        // oszlop index (0-tól, balról jobbra)
    int count;                      // index a táblában
    char figure;                    // ' ' vagy 'O' vagy 'X'

    XPATTERN pattern[4];            // négy irány: K,Ék,É,Dk
    int fieldval[2];                // két játékos: [0]='O', [1]='X'
    int valuedir[2];                // milyen irányú az alakzat

    cell(int r, int c);             // konstruktor

    cell *set();                    // felteszi magát a táblára
    void calcval();                 // kiszámítja a saját értékét
    int maxval();                   // 'X' és 'O' közül az értékesebb
    void modval();                  // újraszámolja a szomszéd cellák értékét

    // osztály adatok
    static int  init;
    static cell *cells[ROWCOL];     // az összes cella tömbje (ez maga a tábla)
    static int spiral[ROWCOL];      // cellák középről kifele sorendben
    static int movestack[ROWCOL];   // lépések
    static int movecount;           // lépésszám
    static int moveforw;            // eddig lehet előremenni (hátralépések után)
    static cell *best_move[2];      // O és X legjobb lépése
    static cell *second_move[2];    // O és X második legjobb lépése
    static char winner;             // ' ' vagy 'O' vagy 'X'
    
    // osztály függvények
    static int classinit();         // inicializálja az osztály adatokat
    static cell *unset();           // leveszi az utolsó figurát a tábláról
    static int  posvalue();         // statikus állás kiértékelés
};


#define BVAL(x)  (cell::best_move[x]?cell::best_move[x]->fieldval[x]:0)
#define BDIR(x)  (cell::best_move[x]?cell::best_move[x]->valuedir[x]:-1)
#define SVAL(x)  (cell::second_move[x]?cell::second_move[x]->fieldval[x]:0)
#define SDIR(x)  (cell::second_move[x]?cell::second_move[x]->valuedir[x]:-1)

