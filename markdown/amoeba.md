<head>
<META charset="UTF-8">
</head>



---------------------------------------------------------------------------------
## Amőba élmény beszámoló

Eredetileg 1984-ben írtam az amőba programot C64-re.
Boltban is kapható volt, a Novotrade forgalmazta. 
Kb. tízezer forintot kerestem vele.
Egyszer még kirakatban is felfedeztem a magnókazettán árult amőbámat, 
csak hogy hallhassam, amit az épp mellettem bámészkodó gamer fiú mond
a barátjának:  "Nézd, van pofájuk amőbával jönni!"

2005-ben csináltam a CCC-GTK interfész könyvtárat, amivel CCC/Clipper 
nyelven lehet grafikus programokat írni Linuxra és Windowsra. 
(Itt lehet olvasni a leírását:
[http://comfirm.hu/ccc3/cccgtk.html ](http://comfirm.hu/ccc3/cccgtk.html).) 
Ez a könyvtár aztán a kezdeti állapotában maradt, nem fejlődött tovább.

A GTK projekt kellemetlenül változékony. Ha írok egy alkalmazást GTK-ra,
és két hónap múlva újra akarom fordítani, kapom a hibaüzeneteket:
Ez vagy az az API megszűnt, vagy deprecated lett, valamelyik struktúra megváltozott.
Nem volt energiám követni az örökös változásokat. Évekig abban merült ki
a CCC-GTK csatoló karbantartása, hogy töröltem belőle azokat az API-kat,
amik a GTK2-ben megváltoztak. Így tartottam lefordítható állapotban.
Azóta lett GTK3 és GTK4 is, de ezekkel nem foglalkoztam. 
Szerencsére a GTK2 mostanra olyan réginek számít, hogy nem piszkálják többé.
Így nyugtom van, a csatoló maradékán már nem kell változtatni, 
úgy jó, ahogy van.

Mindenesetre 2005-ben úgy gondoltam, kellene egy értelmes demó a GTK-hoz.
Emlékezetből újraírtam az amőbát. Húsz év után a részletek már elhalványultak,
és nem is volt sok időm a szöszmötölésre. Így aztán, bár értelmesen játszott,
nem játszott valami erősen az új amőba. Robi barátom könnyen legyőzte.


>  \- Ki nyer ma?  
>  \- Märle Róbert, matematikus.

Sokszor lehetett hallani ezt délben a Kossuthon.
Robi rengetegszeres _Ki nyer ma?_ győztes volt. Az ELGI-ben, a Graphisoftban 
és a KSH-ban dolgozott. Huszonöt éven át hetente együtt furulyáztunk. 
Láttuk felnőni egymás gyerekeit. 2011-ben, ötvenhét évesen nem élte túl a szívműtétet.

Most (2023-ban) rászántam magam: Beleteszem a munkát,
hogy elfogadható játékerővel játsszon a program. Mégis, milyen már, hogy 
a Commodore-64 jobban játszik, mint egy sokezerszeres teljesítményre képes mai PC. 
Tűrhetetlen állapot, ha meggondoljuk.


---------------------------------------------------------------------------------
## Hogyan játszik az Amoeba?

#### 1) Kombinatorikus optimalizálás minimax algoritmussal

Az Amoeba váza ugyanaz, mint a sakkprogramoké, persze ezerszer 
egyszerűbb, minthogy a sakkhoz képest az amőba játék meglehetősen primitív.

Ketten játszanak:

  * a fekete (vagy X) játékos
  * a fehér (vagy O) játékos

Mindkettő nyerni akar. Hogy a két játékos közül melyik áll jobban,
azt az ún. _rating_ mutatja. Ha a rating értéke pozitív, akkor a fekete,
ha negatív, akkor a fehér áll jobban. Természetesen fekete úgy próbál lépni,
hogy a rating a pozitív irányba mozduljon. Fehér ezzel szemben próbálja minél 
inkább csökkenteni a ratinget. 

Vegyünk egy  állást, ahol a fekete van lépésen:
A fekete játékos számbaveszi az értelmes lépéseket, és kiválasztja azt, amelyiktől 
fehér legerősebb válasza esetén is a legjobb eredmény (legmagasabb rating) várható.

Fekete megteszi a lépését, mire fehér következik, aki most hasonló helyzetben van,
csak éppen fordított előjellel: Ki kell választania azt a lépést, amivel fekete
legerősebb válasza esetén a rating minimális.

Fekete  számos lehetőség közül választ. Bármit is választ, az új
pozícióban fehér választja a következő lépést, utána újra fekete, újra fehér, és így tovább. 
A lehetséges lépéssorozatokat ábrázoló gráfot hívjuk _elemzőfának_.
Fekete a maximális ratinget igérő úton halad a fa gyökerétől a levelek felé. 
Fehér ezzel szemben a minimális rating felé vezető útra terel.

A hasonló fákban való optimum keresés kombinatorikus optimalizálási feladat, 
amit a minimax néven ismert algoritmussal oldunk meg. A minimax algoritmus leírását 
megnézhetjük például itt: [https://en.wikipedia.org/wiki/Minimax](https://en.wikipedia.org/wiki/Minimax).
Nincs szükség az elemzőfa minden pontjának kiértékelésére.
Egy ügyes trükk segítségével, az _alfa-béta vágással_, kb. felére lehet csökkenteni
a számítások mennyiségét. Az alfa-béta vágásról olvashatunk itt:
[https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning](https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning).


#### 2) Pozíciók statikus értékelése

Gondolhatnánk, hogy készen is vagyunk. Bejárjuk a teljes elemzőfát.
A fa levelein ismerjük a rating értékét: Egyik vagy másik fél nyert, esetleg
döntetlen, ha a tábla betelt, mielőtt bárki nyert volna. A minimax
algoritmus minden állásban megadja az optimumhoz vezető lépéseket.

Csakhogy a teljes elemzőfa bejárása akármekkora számítási kapacitás mellett
sem lehetséges. Már egy 16x16-os kis tábla esetén is 256! (faktoriális) 
pozíciót kéne kiértékelni. Még ha ez a szám csökkenthető is az alfa-béta 
vágással és egyéb módszerekkel, akkor sem. Ezért az elemzőfa méretét
kénytelenek vagyunk kicsinek tartani. Az elemzőfa ágai nem mindig érik el 
a játék végállását, ezért a leveleken olyan pozícióhoz is ratinget kell 
rendelnünk, ahonnan még folytatódhat a játék.

Az eddigiek bármely hasonló játékra (sakk, go) érvényesek, 
itt azonban színrelépnek az amőba sajátosságai.
Az Amoeba program az alakzatok nyilvántartásával és az alakzatokon végzett
számításokkal dolgozik. Mik azok az alakzatok? Például a fehér kövek 
alábbi elhelyezkedése 

        OOO_O 
    
olyan alakzat, amiben a fehér egylépéses nyerése lehetséges. Ez egy nagyon
értékes alakzat. Vagy nézzük az alábbit:

        _OO__
    
Ha fehér van lépésen, akkor lehetősége van olyan alakzatot létrehozni,
ami kétféle módon is egylépéses nyeréssel fenyeget. Ez is nagyon értékes 
alakzat, bár egy fokkal kevésbé értékes, mint az előző. Az Amoeba program 
az ilyen alakzatok minden fajtáját rendszerezi, számon tartja, kezeli.     

A tábla minden mezője nyolc alakzatban szerepel.  Kelet, Ék, É, Dk négy irány,
négy alakzat, szorozva kettővel, mert mindkét játékos alakzataira figyelni kell.
 
Az alakzatokhoz pontértéket rendelünk. Összegezzük a fekete játékos 
alakzatainak pontértékét, az összegből levonjuk a fehér játékos alakzatait.
Kapunk egy előjeles számot, ami mutatja, hogy a fekete (pozitív) vagy fehér 
(negatív) áll-e jobban. 

Körülbelül így történik a pozíciók statikus értékelése. Sok múlik
az itt nem kifejthető részleteken. Az alakzatokhoz úgy kell pontértéket
rendelni, hogy az jól tükrözze az illető alakzat más alakzatokhoz
viszonyított fontosságát. Amikor az alakzatok összegződnek, akkor
az összegnek értelmes helyre kell kerülnie a pontértékek sorrendjében.


#### 3) Lépés kiválasztás

A csökkentett méretű elemzőfa ágai rövidek: általában nem érnek el 
a játék végállásáig. Az ágak hosszán kívül a fa ágainak számát is
csökkentenünk kell. Képtelenség ugyanis minden lehetséges lépést, vagyis 
a tábla minden  szabad mezejét kiértékelni. Ki kell választanunk azokat a 
fontosnak látszó lépéseket (mezőket), amikkel érdemes foglalkozni, 
azaz érdemes elindítani  rájuk a minimax algoritmust.

Itt is sok múlik a részleteken. Ha fontos mezőket figyelmen kívül hagyunk,
akkor gyengén fog játszani a program, ha mindent beveszünk, akkor pedig
túl lassan. Az Amoeba  a mezőkhöz tartozó alakzatok pontértéke alapján
választja ki a fontos mezőket.


Összegzésként megállapíthatjuk, hogy a játékot (más hasonló játékokkal egyezően) 
három egymásra épülő komponens alkotja:

   - minimax algoritmus
   - statikus állás értékelés
   - lépés kiválasztás

A statikus állás értékelés értéket rendel az elemzőfa leveleihez.
A minimax algoritmus a levelek alapján kiszámítja fontosnak gondolt 
lépésekhez tartozó optimum értéket.

A minimax algoritmuson nincs sok töprengeni való, úgy kell leprogramozni,
ahogy a korábbi linkekben le van írva. A program játékereje azon múlik,
hogy a statikus állás értékelés és a lépés kiválasztás milyen jól
van eltalálva.

Ezért eshet meg, hogy a program, noha értelmesen játszik, mégsem elég erősen. 
A minimax kombinálás akkor is értelem látszatát kölcsönzi a programnak,
ha a másik két komponens viszonylag gyönge. A végállásokban mindig egyértelmű, 
ki a nyerő, ez már ad egy minimális támpontot, ami alapján a minimax jó 
irányba terel. Ettől élvezetes program az Amoeba. Olyan, mintha volna ott valaki, 
aki gondolkodik. Persze nincs, de mégis olyan. Pedig ez még csak nem is AI.


---------------------------------------------------------------------------------
## A program kezelése

#### Indítás

Így indítjuk a programot:

        amoeba.exe [-t <tablesize>] [-p <power>] [<amoebafile>]

Minden paraméter opcionális. A paraméterek default értéke:

  - tablesize: 16
  - power: 0 (auto)
  - amoebafile: üres             

Ha meg van adva, akkor betölti az `<amoebafile>-t`,  és folyathatjuk a játékot, 
vagy elemezhetjük az állást. Ha a `<tablesize>` nincs összhangban azzal a táblával, 
amin a betöltendő játékot eredetileg játszották (és mentették),
akkor a táblaméretet a játékhoz igazítja.            

#### Környezeti változók

A fenti paramétereken kívül környezeti változók is befolyásolják
a program működését.


  -  `export AMOEBA_POWER_WHITE=<power>`  
  A program fehérrel az itt megadott erősséggel játszik
  függetlenül attól, hogy mit állítunk be interaktívan.
  Az erősség lehetséges értékei 0,...,8. A 0 szám felel meg az auto módnak.

  -  `export AMOEBA_POWER_BLACK=<power>`  
  A program feketével az itt megadott erősséggel játszik
  függetlenül attól, hogy mit állítunk be interaktívan.

  -  `export AMOEBA_CONTINUOUS_PLAY=true`    
  A program folyamatosan játszik önmaga ellen. 
  Az előző kettővel  kombinálva ez a beállítás lehetővé teszi, 
  hogy a program  két erősségi szintet játszasson egymás ellen.

  - `export AMOEBA_CELLSIZE=<size>`  
  Beállíthatjuk a tábla mezőinek méretét. A méret 32 és 64 (pixel)
  között változhat.

  - `export AMOEBA_COLOR=<r,g,b>`  
  Beállíthatjuk a tábla színét. Három vesszővel elválasztott számmal,
  0-tól 100-ig terjedő skálán kell megadnunk a red, green, blue színek 
  intenzitását. Egy go tábla színét kapjuk a 77,66,22 számokkal.


#### Interakció

A tábla bármely szabad mezejére egér balgombbal elhelyezhetjük a soron levő
játékos kövét, feltéve, hogy a program éppen nem gondolkodik.


A jobb felső sarokban levő kétállapotú (Ready/Think) címke  mutatja,
hogy a program kész fogadni az inputot, vagy el van foglalva a számításokkal.
Ha éppen gondolkodik, akkor semmilyen inputra nem reagál, meg kell várnunk,
amíg végez, megteszi a lépését, és Ready állapotba kerül.

Ha a program Ready állapotban van, akkor:

  - Egér balgombbal léphetünk (lerakhatjuk a kövünket a táblára).
  
  - Egér jobbgomb mutatja az érdekesebb mezőket _(hint)_.

  - Move gombbal lépésre utasítjuk a programot.

  - Back gomb visszaveszi az utolsó követ.

  - Forward gomb visszarakja az előzőleg levett követ.

  - A Info checkboxszal beállíthatjuk, hogy mutassa a lépést,
    amin éppen gondolkodik. Az ablak tetején látjuk a legjobbnak 
    talált lépés sorozatot.  Ha ezek ki vannak kapcsolva, akkor a humán 
    játékosnak nem marad sok esélye. Ha a programot konzolból futtatjuk, 
    akkor infó  módban listázza a kiértékelt mezőkben talált alakzatokat. 

  - Az Recalc  gombbal megpróbálhatunk a táblán megtett utolsó lépésnél erősebbet
    keresni. A gomb működése:

    1. Leveszi a tábláról az utolsó követ. 
    2. Megkeresi a listboxban beállított elemzőfával megtalálható legerősebb lépést.
    3. Megmutatja a lépést, e célból egy kicsit hunyorog.
    4. Visszarakja az eredeti állást.

    Az eredeti állás visszarakása után a Back és Forward gombok a korábbi
    változatlan lépéssorozaton navigálnak előre és hátra. Ez a funkció
    mindig a listboxban interaktívan beállított elemzőfát használja,
    függetlenül az `AMOEBA_POWER` környezeti változóktól.

  - Az Recalc alatti listboxban beállíthatjuk az elemzőfa méretét.
    Auto beállításnál a program a lépésszám előrehaladtával
    egyre terjedelmesebb elemzőfát használ. Nem érdemes  túl nagy fát
    választani, mert lassú lesz a program. Windowson különösen lassú lesz.


    
  - New gomb kiüríti a táblát, új játék kezdhető.
  
  - Load gombbal betölthetünk egy korábban elmentett állást. 
    Csak olyan állást tölt be, aminek a táblamérete azonos
    az aktuális táblamérettel.
  
  - Save gomb elmenti az aktuális állást.

Az ablak alsó részén látjuk az utolsó lépést, hogy ki van lépésen, 
mi az állás értékelése.


---------------------------------------------------------------------------------
## Milyen nyelven íródott az Amoeba?

A program kb. fele-fele arányban  CCC-ben és C++ ban készült. 

CCC-ben van

  - a főprogram,
  - a GTK-ra alapozott grafikus interfész,
  - a minimax algoritmus.
    
C++-ban van

  - a táblán levő állás és az alakzatok nyilvántartása,
  - a tábla és a kövek kirajzolása ([Cairo](https://en.wikipedia.org/wiki/Cairo_(graphics)) könyvtárral),
  - a statikus állás értékelés,
  - a lépés kiválasztás.    
    


---------------------------------------------------------------------------------
## Letöltés

A program forrása git-tel tölthető le:

        git clone git://comfirm.hu/amoeba.git

Linuxon [CCC3](http://comfirm.hu/ccc3/ccc-belulrol.html)
környezetben vagy Windowson MSYS2+CCC3 környezetben tudjuk lefordítani.

Windows 10-re lefordított, MSYS2 és CCC környezet nélkül futtatható zip csomag
tölthető le innen: [https://comfirm.hu/pub/amoeba.zip](https://comfirm.hu/pub/amoeba.zip)
   

Hangsúlyozom, hogy a program elsősorban linuxos. A windowsos verzió halvány
árnyéka a linuxosnak. Eleve Windowson minden ötször lassabb. Ez annak ellenére van így, 
hogy az `amoeba.exe` és a hozzá tartozó `dll`-ek natív Windows programok, 
nincs szó valamiféle Linux emulációról. 
Abban sem vagyok biztos, hogy másvalaki gépén jól jelenik-e meg. A megjelenés függ attól, 
hogy milyen fontok vannak installálva a rendszeren, milyen a képernyő felbontása és 
hasonlók. Annyit mondhatok csak, hogy a saját Linux boxomban virtualizált Windows 10-en 
elfogadhatóan működik.


---------------------------------------------------------------------------------
## Online játék

Böngészőben is lehet amőbázni a következő linken:
[Amoeba for the WEB](http://comfirm.hu:45678/webapp).

A webes változat a szerveren játszik, a böngésző csak a megjelenítést végzi.
E sorok írásakor a szerver egy Intel Celeron J1900 (4) @ 2.415GHz processzoron futó 
Arch Linux. A szerény teljesítményű CPU-tól ne várjunk nagy sebességet. 


---------------------------------------------------------------------------------



