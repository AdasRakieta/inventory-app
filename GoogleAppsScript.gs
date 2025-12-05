// --- KONFIGURACJA ---
// WPISZ TUTAJ ID SWOJEGO ARKUSZA FIRMOWEGO:
var ID_ARKUSZA = "1F3-1b2ZkpqZWIUBgJXWzrTylLdnnSZ9d7gfNUoMXFOU";

var KONFIGURACJA = [
  { nazwa: "Skanery", colKod: 1, colStatus: 2 },
  { nazwa: "Drukarki", colKod: 1, colStatus: 2 },
  { nazwa: "Stacje do drukarek", colKod: 1, colStatus: 2 },
  { nazwa: "Stacje Dokujące", colKod: 1, colStatus: 2 },
  { nazwa: "Skanery tc27", colKod: 1, colStatus: 2 },
];
// --- KONIEC KONFIGURACJI ---

/**
 * Główna funkcja obsługująca GET requests - pobieranie danych z arkusza
 */
function doGet(e) {
  var nazwaArkusza = e.parameter.arkusz;
  if (!nazwaArkusza) {
    return ContentService.createTextOutput(JSON.stringify({
      status: "BLAD",
      message: "Podaj nazwę arkusza w URL"
    })).setMimeType(ContentService.MimeType.JSON);
  }

  try {
    // Otwieramy arkusz po ID z konfiguracji
    var ss = SpreadsheetApp.openById(ID_ARKUSZA);
    var sheet = ss.getSheetByName(nazwaArkusza);

    if (!sheet) {
      return ContentService.createTextOutput(JSON.stringify({
        status: "BLAD",
        message: "Nie znaleziono arkusza: " + nazwaArkusza
      })).setMimeType(ContentService.MimeType.JSON);
    }

    var data = sheet.getDataRange().getValues();
    if (data.length === 0) {
      return ContentService.createTextOutput(JSON.stringify({
        status: "SUKCES",
        data: []
      })).setMimeType(ContentService.MimeType.JSON);
    }

    var headers = data[0];
    var result = [];
    
    for (var i = 1; i < data.length; i++) {
      var rowObj = {};
      var hasData = false;
      
      for (var j = 0; j < headers.length; j++) {
        rowObj[headers[j]] = data[i][j];
        if (data[i][j] !== "") hasData = true;
      }
      
      if (hasData) result.push(rowObj);
    }
    
    return ContentService.createTextOutput(JSON.stringify(result)).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    Logger.log("Błąd w doGet: " + error.toString());
    return ContentService.createTextOutput(JSON.stringify({
      status: "BLAD",
      message: "Błąd pobierania: " + error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Główna funkcja obsługująca POST requests
 */
function doPost(e) {
  try {
    var params = JSON.parse(e.postData.contents);
    var akcja = params.akcja;
    
    Logger.log("Otrzymano żądanie: " + akcja);
    
    if (akcja === "bulk") {
      return obslugaBulk(params);
    } else if (akcja === "insert") {
      return obslugaInsert(params);
    } else if (akcja === "update") {
      return obslugaUpdate(params);
    } else {
      return ContentService.createTextOutput(JSON.stringify({
        success: false,
        message: "Nieznana akcja: " + akcja
      })).setMimeType(ContentService.MimeType.JSON);
    }
  } catch (error) {
    Logger.log("Błąd w doPost: " + error.toString());
    return ContentService.createTextOutput(JSON.stringify({
      success: false,
      message: "Błąd serwera: " + error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * ZOPTYMALIZOWANA funkcja obsługująca bulk operations
 * - Grupuje operacje po arkuszach
 * - Jednorazowe odczytanie danych z każdego arkusza
 * - Wszystkie operacje wykonywane w pamięci
 * - Jednorazowy zapis do każdego arkusza
 * - Dynamiczne wyszukiwanie kolumn po nazwach nagłówków
 */
function obslugaBulk(params) {
  var operacje = params.operacje;
  
  if (!operacje || !Array.isArray(operacje) || operacje.length === 0) {
    return ContentService.createTextOutput(JSON.stringify({
      success: false,
      message: "Brak operacji do wykonania"
    })).setMimeType(ContentService.MimeType.JSON);
  }
  
  Logger.log("Rozpoczęcie bulk upload: " + operacje.length + " operacji");
  
  // Używamy ID_ARKUSZA z konfiguracji
  var ss = SpreadsheetApp.openById(ID_ARKUSZA);
  var updateCount = 0;
  var insertCount = 0;
  var errorCount = 0;
  var errors = [];
  
  // Grupowanie operacji po arkuszach
  var operacjePoArkuszach = {};
  for (var i = 0; i < operacje.length; i++) {
    var op = operacje[i];
    var arkuszNazwa = op.arkusz;
    
    if (!operacjePoArkuszach[arkuszNazwa]) {
      operacjePoArkuszach[arkuszNazwa] = [];
    }
    operacjePoArkuszach[arkuszNazwa].push(op);
  }
  
  // Przetwarzanie każdego arkusza
  var arkusze = Object.keys(operacjePoArkuszach);
  for (var a = 0; a < arkusze.length; a++) {
    var arkuszNazwa = arkusze[a];
    var arkuszOperacje = operacjePoArkuszach[arkuszNazwa];
    
    try {
      var sheet = ss.getSheetByName(arkuszNazwa);
      if (!sheet) {
        Logger.log("BŁĄD: Nie znaleziono arkusza: " + arkuszNazwa);
        errorCount += arkuszOperacje.length;
        errors.push("Nie znaleziono arkusza: " + arkuszNazwa);
        continue;
      }
      
      // Jednorazowe pobranie wszystkich danych z arkusza
      var dataRange = sheet.getDataRange();
      var allData = dataRange.getValues();
      
      if (allData.length === 0) {
        Logger.log("BŁĄD: Pusty arkusz: " + arkuszNazwa);
        errorCount += arkuszOperacje.length;
        errors.push("Pusty arkusz: " + arkuszNazwa);
        continue;
      }
      
      var headers = allData[0];
      
      // MOBILNE MAPOWANIE - Znalezienie indeksów kolumn dynamicznie
      // Kolumna A to zawsze "Urzadzenie", następna kolumna to SN (nazwa arkusza)
      var ci = {
        urzadzenie: findColumnIndex(headers, "Urzadzenie"),
        sn: findSnColumnIndex(headers, arkuszNazwa),
        status: findColumnIndex(headers, "Status"),
        kod: findColumnIndex(headers, "Kod"),
        nazwa: findColumnIndex(headers, "Nazwa"),
        miejsce: findColumnIndex(headers, "Miejsce"),
        firma: findColumnIndex(headers, "Firma"),
        komentarz: findColumnIndex(headers, "Komentarz"),
        kategoria: findColumnIndex(headers, "Kategoria"),
        data: findColumnIndex(headers, "Data"),
        model: findColumnIndex(headers, "Model")
      };
      
      Logger.log("Indeksy kolumn dla " + arkuszNazwa + ": " + JSON.stringify(ci));
      
      if (ci.sn === -1) {
        Logger.log("BŁĄD: Nie znaleziono kolumny SN dla: " + arkuszNazwa);
        errorCount += arkuszOperacje.length;
        errors.push("Brak kolumny SN w arkuszu: " + arkuszNazwa);
        continue;
      }
      
      // Budowanie mapy SN -> indeks wiersza dla szybkiego wyszukiwania
      var snToRow = {};
      for (var r = 1; r < allData.length; r++) {
        var sn = allData[r][ci.sn];
        if (sn) {
          snToRow[sn.toString().trim()] = r;
        }
      }
      
      var noweWiersze = [];
      
      // Przetwarzanie operacji dla tego arkusza
      for (var j = 0; j < arkuszOperacje.length; j++) {
        var op = arkuszOperacje[j];
        
        try {
          if (op.typ === "update") {
            // UPDATE - znajdź wiersz po SN i zaktualizuj
            var rowIdx = snToRow[op.serialNumber];
            
            if (rowIdx !== undefined) {
              var row = allData[rowIdx];
              
              // Aktualizacja tylko niepustych wartości z operacji
              if (op.status && ci.status !== -1) {
                row[ci.status] = op.status;
              }
              if (op.kod && ci.kod !== -1) {
                row[ci.kod] = op.kod;
              }
              if (op.nazwa && ci.nazwa !== -1) {
                row[ci.nazwa] = op.nazwa;
              }
              if (op.miejsce && ci.miejsce !== -1) {
                row[ci.miejsce] = op.miejsce;
              }
              
              updateCount++;
              Logger.log("UPDATE: " + op.serialNumber + " w wierszu " + (rowIdx + 1));
            } else {
              Logger.log("UWAGA: Nie znaleziono SN dla UPDATE: " + op.serialNumber + " - pomijam");
              errorCount++;
              errors.push("Nie znaleziono SN dla UPDATE: " + op.serialNumber);
            }
            
          } else if (op.typ === "insert") {
            // UPSERT - jeśli SN istnieje, wykonaj UPDATE; inaczej INSERT
            if (!op.dane) {
              Logger.log("BŁĄD: Brak danych dla INSERT");
              errorCount++;
              errors.push("Brak danych dla INSERT: " + op.serialNumber);
              continue;
            }
            
            var nd = op.dane;
            var newRow = new Array(headers.length).fill("");
            
            // MOBILNE WYPEŁNIENIE - mapowanie po indeksach kolumn
            for (var c = 0; c < headers.length; c++) {
              var v = "";
              
              if (c === ci.urzadzenie && ci.urzadzenie !== -1) {
                v = nd.Urzadzenie || "";
              } else if (c === ci.sn && ci.sn !== -1) {
                v = nd.serialNumber || "";
              } else if (c === ci.status && ci.status !== -1) {
                v = nd.Status || "";
              } else if (c === ci.kod && ci.kod !== -1) {
                v = nd.Kod || "";
              } else if (c === ci.nazwa && ci.nazwa !== -1) {
                v = nd.Nazwa || "";
              } else if (c === ci.miejsce && ci.miejsce !== -1) {
                v = nd.Miejsce || "";
              } else if (c === ci.firma && ci.firma !== -1) {
                v = nd.Firma || "";
              } else if (c === ci.komentarz && ci.komentarz !== -1) {
                v = nd.Komentarz || "";
              } else if (c === ci.kategoria && ci.kategoria !== -1) {
                v = nd.Kategoria || "";
              } else if (c === ci.data && ci.data !== -1) {
                v = nd.Data || "";
              } else if (c === ci.model && ci.model !== -1) {
                v = nd.Model || "";
              }
              newRow[c] = v;
            }

            var trimmedSn = (nd.serialNumber || "").toString().trim();
            if (trimmedSn && snToRow.hasOwnProperty(trimmedSn)) {
              // SN istnieje — potraktuj jako UPDATE
              var existingRowIdx = snToRow[trimmedSn];
              allData[existingRowIdx] = newRow;
              updateCount++;
              Logger.log("UPSERT->UPDATE: " + nd.serialNumber + " w wierszu " + (existingRowIdx + 1));
            } else {
              // Nowy SN — klasyczny INSERT
              noweWiersze.push(newRow);
              insertCount++;
              Logger.log("INSERT: " + nd.serialNumber);
            }
          }
          
        } catch (opError) {
          Logger.log("BŁĄD w operacji: " + opError.toString());
          errorCount++;
          errors.push("Błąd operacji " + op.typ + " dla " + op.serialNumber + ": " + opError.toString());
        }
      }
      
      // Jednorazowy zapis zaktualizowanych danych
      if (allData.length > 0) {
        dataRange.setValues(allData);
        Logger.log("Zapisano " + allData.length + " wierszy do " + arkuszNazwa);
      }
      
      // Dodanie nowych wierszy jeśli są (z zachowaniem formuł/formatowania)
      if (noweWiersze.length > 0) {
        var lastRow = sheet.getLastRow();
        var insertBeforeFormulas = false;

        // Sprawdź czy ostatni wiersz zawiera formuły (np. SUM, LICZ)
        if (lastRow > 1) {
          try {
            var lastRowRange = sheet.getRange(lastRow, 1, 1, sheet.getLastColumn());
            var lastRowFormulas = lastRowRange.getFormulas()[0];
            for (var f = 0; f < lastRowFormulas.length; f++) {
              if (lastRowFormulas[f] !== "") {
                insertBeforeFormulas = true;
                break;
              }
            }
          } catch (e) {
            insertBeforeFormulas = false; // w razie błędu dodaj na końcu
          }
        }

        if (insertBeforeFormulas) {
          // Wstaw PRZED wierszem z formułami
          sheet.insertRowsBefore(lastRow, noweWiersze.length);
          var insertRange = sheet.getRange(lastRow, 1, noweWiersze.length, noweWiersze[0].length);
          insertRange.setValues(noweWiersze);
          Logger.log("Dodano " + noweWiersze.length + " wierszy przed wierszem z formułami w " + arkuszNazwa);
        } else {
          // Brak formuł w ostatnim wierszu – dodaj na końcu
          var startRow = lastRow + 1;
          var range = sheet.getRange(startRow, 1, noweWiersze.length, noweWiersze[0].length);
          range.setValues(noweWiersze);
          Logger.log("Dodano " + noweWiersze.length + " nowych wierszy na końcu " + arkuszNazwa);
        }
      }
      
    } catch (sheetError) {
      Logger.log("BŁĄD w arkuszu " + arkuszNazwa + ": " + sheetError.toString());
      errorCount += arkuszOperacje.length;
      errors.push("Błąd arkusza " + arkuszNazwa + ": " + sheetError.toString());
    }
  }
  
  var totalProcessed = updateCount + insertCount + errorCount;
  var message = "Bulk upload zakończony: " + updateCount + " zaktualizowanych, " + 
                insertCount + " dodanych, " + errorCount + " błędów";
  
  if (errors.length > 0) {
    message += ". Błędy: " + errors.join("; ");
  }
  
  Logger.log(message);
  
  return ContentService.createTextOutput(JSON.stringify({
    success: errorCount === 0,
    message: message,
    updateCount: updateCount,
    insertCount: insertCount,
    errorCount: errorCount,
    totalProcessed: totalProcessed
  })).setMimeType(ContentService.MimeType.JSON);
}

/**
 * Znajduje indeks kolumny Serial Number na podstawie nazwy arkusza
 * WAŻNE: Nazwy kolumn SN są takie same jak nazwy arkuszy
 * - "Skanery" ma kolumnę "Skanery"
 * - "Drukarki" ma kolumnę "Drukarki"
 * - "Stacje do drukarek" ma kolumnę "Stacje do drukarek"
 * - "Stacje Dokujące" ma kolumnę "Stacje Dokujące"
 */
function findSnColumnIndex(headers, sheetName) {
  // POPRAWKA: Kolumna SN ma dokładnie taką samą nazwę jak arkusz
  var snNames = [sheetName];
  
  // Dodatkowe warianty dla kompatybilności
  if (sheetName === "Skanery tc27") {
    snNames = ["Skanery tc27", "Skanery"];
  } else if (sheetName === "Stacje Dokujące") {
    snNames = ["Stacje Dokujące", "Stacje dokujące"];
  }
  
  // Szukanie kolumny - priorytet dla dokładnego dopasowania
  for (var i = 0; i < headers.length; i++) {
    var h = headers[i].toString().trim();
    for (var j = 0; j < snNames.length; j++) {
      if (h === snNames[j]) {
        return i;
      }
    }
  }
  
  return -1;
}

/**
 * Znajduje indeks kolumny po nazwie nagłówka
 * Obsługuje zarówno polskie znaki (Urządzenie) jak i bez (Urzadzenie)
 */
function findColumnIndex(headers, columnName) {
  // Warianty nazw z polskimi znakami
  var variants = [columnName];
  
  if (columnName === "Urzadzenie") {
    variants = ["Urządzenie", "Urzadzenie"];
  } else if (columnName === "Miejsce") {
    variants = ["Miejsce", "Miejsce"];
  }
  
  for (var i = 0; i < headers.length; i++) {
    var h = headers[i].toString().trim();
    for (var j = 0; j < variants.length; j++) {
      if (h === variants[j]) {
        return i;
      }
    }
  }
  return -1;
}

/**
 * Obsługa pojedynczego INSERT
 */
function obslugaInsert(params) {
  try {
    var ss = SpreadsheetApp.openById(ID_ARKUSZA);
    var arkuszNazwa = params.arkusz;
    var sheet = ss.getSheetByName(arkuszNazwa);
    
    if (!sheet) {
      return ContentService.createTextOutput(JSON.stringify({
        success: false,
        message: "Nie znaleziono arkusza: " + arkuszNazwa
      })).setMimeType(ContentService.MimeType.JSON);
    }
    
    var dane = params.dane;
    var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
    
    // MOBILNE MAPOWANIE dla pojedynczego INSERT
    var ci = {
      urzadzenie: findColumnIndex(headers, "Urzadzenie"),
      sn: findSnColumnIndex(headers, arkuszNazwa),
      status: findColumnIndex(headers, "Status"),
      kod: findColumnIndex(headers, "Kod"),
      nazwa: findColumnIndex(headers, "Nazwa"),
      miejsce: findColumnIndex(headers, "Miejsce"),
      firma: findColumnIndex(headers, "Firma"),
      komentarz: findColumnIndex(headers, "Komentarz"),
      kategoria: findColumnIndex(headers, "Kategoria"),
      data: findColumnIndex(headers, "Data"),
      model: findColumnIndex(headers, "Model")
    };
    
    var newRow = new Array(headers.length).fill("");
    
    for (var c = 0; c < headers.length; c++) {
      if (c === ci.urzadzenie && ci.urzadzenie !== -1) newRow[c] = dane.Urzadzenie || "";
      else if (c === ci.sn && ci.sn !== -1) newRow[c] = dane.serialNumber || "";
      else if (c === ci.status && ci.status !== -1) newRow[c] = dane.Status || "";
      else if (c === ci.kod && ci.kod !== -1) newRow[c] = dane.Kod || "";
      else if (c === ci.nazwa && ci.nazwa !== -1) newRow[c] = dane.Nazwa || "";
      else if (c === ci.miejsce && ci.miejsce !== -1) newRow[c] = dane.Miejsce || "";
      else if (c === ci.firma && ci.firma !== -1) newRow[c] = dane.Firma || "";
      else if (c === ci.komentarz && ci.komentarz !== -1) newRow[c] = dane.Komentarz || "";
      else if (c === ci.kategoria && ci.kategoria !== -1) newRow[c] = dane.Kategoria || "";
      else if (c === ci.data && ci.data !== -1) newRow[c] = dane.Data || "";
      else if (c === ci.model && ci.model !== -1) newRow[c] = dane.Model || "";
    }
    
    // UPSERT: jeśli SN już istnieje w arkuszu, wykonaj UPDATE zamiast INSERT
    var existingData = sheet.getDataRange().getValues();
    var headersLocal = existingData[0];
    var snCol = findSnColumnIndex(headersLocal, arkuszNazwa);
    var foundRow = -1;
    if (snCol !== -1) {
      for (var r = 1; r < existingData.length; r++) {
        if (existingData[r][snCol] && existingData[r][snCol].toString().trim() === (dane.serialNumber || "").toString().trim()) {
          foundRow = r + 1; // arkusz jest 1-indeksowany
          break;
        }
      }
    }

    if (foundRow !== -1) {
      // UPDATE istniejącego wiersza
      sheet.getRange(foundRow, 1, 1, newRow.length).setValues([newRow]);
      Logger.log("UPSERT->UPDATE w wierszu " + foundRow + " w arkuszu " + arkuszNazwa);
    } else {
      // Sprawdź czy ostatni wiersz ma formuły - jeśli tak, wstaw przed nim
      var lastRow = sheet.getLastRow();
      var insertBeforeFormulas = false;
      
      if (lastRow > 1) {
        try {
          var lastRowRange = sheet.getRange(lastRow, 1, 1, sheet.getLastColumn());
          var lastRowFormulas = lastRowRange.getFormulas()[0];
          for (var f = 0; f < lastRowFormulas.length; f++) {
            if (lastRowFormulas[f] !== "") {
              insertBeforeFormulas = true;
              break;
            }
          }
        } catch (e) {
          insertBeforeFormulas = false;
        }
      }
      
      if (insertBeforeFormulas) {
        // Wstaw PRZED ostatnim wierszem (który ma formuły)
        sheet.insertRowsBefore(lastRow, 1);
        sheet.getRange(lastRow, 1, 1, newRow.length).setValues([newRow]);
        Logger.log("Dodano wiersz przed wierszem z formułami w " + arkuszNazwa);
      } else {
        // Dodaj na końcu
        sheet.appendRow(newRow);
        Logger.log("Dodano wiersz na końcu " + arkuszNazwa);
      }
    }
    
    return ContentService.createTextOutput(JSON.stringify({
      success: true,
      message: "Dodano wiersz do " + arkuszNazwa
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({
      success: false,
      message: "Błąd INSERT: " + error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Obsługa pojedynczego UPDATE
 */
function obslugaUpdate(params) {
  try {
    var ss = SpreadsheetApp.openById(ID_ARKUSZA);
    var arkuszNazwa = params.arkusz;
    var sheet = ss.getSheetByName(arkuszNazwa);
    
    if (!sheet) {
      return ContentService.createTextOutput(JSON.stringify({
        success: false,
        message: "Nie znaleziono arkusza: " + arkuszNazwa
      })).setMimeType(ContentService.MimeType.JSON);
    }
    
    var serialNumber = params.serialNumber;
    var allData = sheet.getDataRange().getValues();
    var headers = allData[0];
    
    var ci = {
      sn: findSnColumnIndex(headers, arkuszNazwa),
      status: findColumnIndex(headers, "Status"),
      kod: findColumnIndex(headers, "Kod"),
      nazwa: findColumnIndex(headers, "Nazwa"),
      miejsce: findColumnIndex(headers, "Miejsce")
    };
    
    // Znajdź wiersz z danym SN
    var rowIndex = -1;
    for (var r = 1; r < allData.length; r++) {
      if (allData[r][ci.sn] && allData[r][ci.sn].toString().trim() === serialNumber) {
        rowIndex = r;
        break;
      }
    }
    
    if (rowIndex === -1) {
      return ContentService.createTextOutput(JSON.stringify({
        success: false,
        message: "Nie znaleziono wiersza z SN: " + serialNumber
      })).setMimeType(ContentService.MimeType.JSON);
    }
    
    // Aktualizuj tylko podane wartości
    if (params.status && ci.status !== -1) {
      sheet.getRange(rowIndex + 1, ci.status + 1).setValue(params.status);
    }
    if (params.kod && ci.kod !== -1) {
      sheet.getRange(rowIndex + 1, ci.kod + 1).setValue(params.kod);
    }
    if (params.nazwa && ci.nazwa !== -1) {
      sheet.getRange(rowIndex + 1, ci.nazwa + 1).setValue(params.nazwa);
    }
    if (params.miejsce && ci.miejsce !== -1) {
      sheet.getRange(rowIndex + 1, ci.miejsce + 1).setValue(params.miejsce);
    }
    
    return ContentService.createTextOutput(JSON.stringify({
      success: true,
      message: "Zaktualizowano wiersz " + (rowIndex + 1) + " w " + arkuszNazwa
    })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({
      success: false,
      message: "Błąd UPDATE: " + error.toString()
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

// ============================================================
// FUNKCJE TESTOWE - DO TESTOWANIA W EDYTORZE APPS SCRIPT
// ============================================================

/**
 * FUNKCJA TESTOWA: Bulk Insert
 * Testuje dodawanie wielu nowych produktów naraz
 * Uruchom tę funkcję w edytorze Apps Script aby przetestować bulk insert
 */
function testBulkInsert() {
  Logger.log("=== TEST BULK INSERT ===");
  
  var testParams = {
    akcja: "bulk",
    operacje: [
      {
        typ: "insert",
        arkusz: "Skanery",
        serialNumber: "TEST001",
        dane: {
          serialNumber: "TEST001",
          Urzadzenie: "Zebra TC58E Test Device",
          Status: "Magazyn",
          Kod: "PKG-TEST-001",
          Nazwa: "Test Package 1",
          Miejsce: "Warszawa",
          Firma: "Test Firma 1",
          Komentarz: "Test bulk insert 1",
          Kategoria: "1L"
        }
      },
      {
        typ: "insert",
        arkusz: "Skanery",
        serialNumber: "TEST002",
        dane: {
          serialNumber: "TEST002",
          Urzadzenie: "Zebra TC58E Test Device 2",
          Status: "Przygotowanie",
          Kod: "PKG-TEST-002",
          Nazwa: "Test Package 2",
          Miejsce: "Kraków",
          Firma: "Test Firma 2",
          Komentarz: "Test bulk insert 2",
          Kategoria: "1L"
        }
      },
      {
        typ: "insert",
        arkusz: "Drukarki",
        serialNumber: "TEST_PRINTER_001",
        dane: {
          serialNumber: "TEST_PRINTER_001",
          Urzadzenie: "Zebra ZQ630 Test Printer",
          Status: "Magazyn",
          Kod: "PKG-TEST-003",
          Nazwa: "Test Package 3",
          Miejsce: "Gdańsk",
          Firma: "Test Firma 3",
          Komentarz: "Test bulk insert drukarki",
          Kategoria: "2L"
        }
      }
    ]
  };
  
  Logger.log("Wysyłanie " + testParams.operacje.length + " operacji INSERT...");
  
  var result = obslugaBulk(testParams);
  var resultText = result.getContent();
  var resultObj = JSON.parse(resultText);
  
  Logger.log("=== WYNIK TESTU ===");
  Logger.log("Success: " + resultObj.success);
  Logger.log("Message: " + resultObj.message);
  Logger.log("Insert Count: " + resultObj.insertCount);
  Logger.log("Update Count: " + resultObj.updateCount);
  Logger.log("Error Count: " + resultObj.errorCount);
  Logger.log("Total Processed: " + resultObj.totalProcessed);
  
  if (resultObj.success) {
    Logger.log("✓ TEST BULK INSERT ZAKOŃCZONY SUKCESEM");
  } else {
    Logger.log("✗ TEST BULK INSERT ZAKOŃCZONY BŁĘDEM");
  }
  
  return resultObj;
}

/**
 * FUNKCJA TESTOWA: Bulk Update
 * Testuje aktualizację istniejących produktów naraz
 * UWAGA: Upewnij się, że produkty TEST001, TEST002 istnieją (uruchom najpierw testBulkInsert)
 */
function testBulkUpdate() {
  Logger.log("=== TEST BULK UPDATE ===");
  
  var testParams = {
    akcja: "bulk",
    operacje: [
      {
        typ: "update",
        arkusz: "Skanery",
        serialNumber: "TEST001",
        status: "Wydano",
        kod: "PKG-TEST-001-UPDATED",
        nazwa: "Test Package 1 UPDATED",
        miejsce: "Wrocław"
      },
      {
        typ: "update",
        arkusz: "Skanery",
        serialNumber: "TEST002",
        status: "Zwrócono",
        kod: "PKG-TEST-002-UPDATED",
        nazwa: "Test Package 2 UPDATED",
        miejsce: "Poznań"
      },
      {
        typ: "update",
        arkusz: "Drukarki",
        serialNumber: "TEST_PRINTER_001",
        status: "Do wysyłki",
        kod: "PKG-TEST-003-UPDATED",
        nazwa: "Test Package 3 UPDATED",
        miejsce: "Łódź"
      }
    ]
  };
  
  Logger.log("Wysyłanie " + testParams.operacje.length + " operacji UPDATE...");
  
  var result = obslugaBulk(testParams);
  var resultText = result.getContent();
  var resultObj = JSON.parse(resultText);
  
  Logger.log("=== WYNIK TESTU ===");
  Logger.log("Success: " + resultObj.success);
  Logger.log("Message: " + resultObj.message);
  Logger.log("Insert Count: " + resultObj.insertCount);
  Logger.log("Update Count: " + resultObj.updateCount);
  Logger.log("Error Count: " + resultObj.errorCount);
  Logger.log("Total Processed: " + resultObj.totalProcessed);
  
  if (resultObj.success) {
    Logger.log("✓ TEST BULK UPDATE ZAKOŃCZONY SUKCESEM");
  } else {
    Logger.log("✗ TEST BULK UPDATE ZAKOŃCZONY BŁĘDEM");
  }
  
  return resultObj;
}

/**
 * FUNKCJA TESTOWA: Bulk Mixed (INSERT + UPDATE)
 * Testuje mieszane operacje - dodawanie nowych i aktualizację istniejących
 */
function testBulkMixed() {
  Logger.log("=== TEST BULK MIXED (INSERT + UPDATE) ===");
  
  var testParams = {
    akcja: "bulk",
    operacje: [
      // UPDATE istniejących
      {
        typ: "update",
        arkusz: "Skanery",
        serialNumber: "TEST001",
        status: "Magazyn",
        kod: "PKG-BACK-TO-WAREHOUSE",
        nazwa: "Returned to warehouse",
        miejsce: "Magazyn Centralny"
      },
      // INSERT nowego
      {
        typ: "insert",
        arkusz: "Stacje Dokujące",
        serialNumber: "TEST_DOCK_001",
        dane: {
          serialNumber: "TEST_DOCK_001",
          Urzadzenie: "Zebra Docking Station Test",
          Status: "Magazyn",
          Kod: "PKG-TEST-DOCK-001",
          Nazwa: "Test Docking Package",
          Miejsce: "Warszawa",
          Firma: "Test Firma Dock",
          Komentarz: "Test stacji dokującej",
          Kategoria: "3L"
        }
      },
      // UPDATE kolejnego istniejącego
      {
        typ: "update",
        arkusz: "TEST002",
        serialNumber: "TEST002",
        status: "Magazyn",
        miejsce: "Magazyn Centralny"
      }
    ]
  };
  
  Logger.log("Wysyłanie " + testParams.operacje.length + " mieszanych operacji...");
  
  var result = obslugaBulk(testParams);
  var resultText = result.getContent();
  var resultObj = JSON.parse(resultText);
  
  Logger.log("=== WYNIK TESTU ===");
  Logger.log("Success: " + resultObj.success);
  Logger.log("Message: " + resultObj.message);
  Logger.log("Insert Count: " + resultObj.insertCount);
  Logger.log("Update Count: " + resultObj.updateCount);
  Logger.log("Error Count: " + resultObj.errorCount);
  Logger.log("Total Processed: " + resultObj.totalProcessed);
  
  if (resultObj.success) {
    Logger.log("✓ TEST BULK MIXED ZAKOŃCZONY SUKCESEM");
  } else {
    Logger.log("✗ TEST BULK MIXED ZAKOŃCZONY BŁĘDEM");
  }
  
  return resultObj;
}

/**
 * FUNKCJA POMOCNICZA: Usuń testowe dane
 * Czyści wszystkie wiersze z testowymi SN (TEST*)
 * Uruchom po zakończeniu testów aby wyczyścić arkusze
 */
function cleanupTestData() {
  Logger.log("=== CZYSZCZENIE DANYCH TESTOWYCH ===");
  
  var ss = SpreadsheetApp.openById(ID_ARKUSZA);
  var sheetNames = ["Skanery", "Drukarki", "Stacje Dokujące"];
  var deletedCount = 0;
  
  for (var s = 0; s < sheetNames.length; s++) {
    var sheetName = sheetNames[s];
    var sheet = ss.getSheetByName(sheetName);
    
    if (!sheet) {
      Logger.log("Pominięto arkusz (nie znaleziono): " + sheetName);
      continue;
    }
    
    var allData = sheet.getDataRange().getValues();
    var headers = allData[0];
    var snColIndex = findSnColumnIndex(headers, sheetName);
    
    if (snColIndex === -1) {
      Logger.log("Pominięto arkusz (brak kolumny SN): " + sheetName);
      continue;
    }
    
    // Usuwanie od końca aby nie psuć indeksów
    for (var r = allData.length - 1; r >= 1; r--) {
      var sn = allData[r][snColIndex];
      if (sn && sn.toString().indexOf("TEST") === 0) {
        sheet.deleteRow(r + 1);
        deletedCount++;
        Logger.log("Usunięto wiersz " + (r + 1) + " z SN: " + sn + " w arkuszu " + sheetName);
      }
    }
  }
  
  Logger.log("=== CZYSZCZENIE ZAKOŃCZONE ===");
  Logger.log("Usunięto " + deletedCount + " wierszy testowych");
  
  return deletedCount;
}
