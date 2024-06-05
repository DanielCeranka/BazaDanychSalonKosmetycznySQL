-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Cze 05, 2024 at 02:18 PM
-- Wersja serwera: 10.4.32-MariaDB
-- Wersja PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `salon_kosmetyczny`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddNewClient` (IN `p_imie` VARCHAR(50), IN `p_nazwisko` VARCHAR(50), IN `p_email` VARCHAR(100), IN `p_telefon` VARCHAR(20))   BEGIN
    INSERT INTO Klienci (imię, nazwisko, email, telefon)
    VALUES (p_imie, p_nazwisko, p_email, p_telefon);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ilosc_pracownikow` ()   BEGIN
    SELECT COUNT(*) AS liczba_pracownikow FROM Pracownicy;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MakeReservation` (IN `p_klient_ID` INT, IN `p_pracownik_ID` INT, IN `p_usluga_ID` INT, IN `p_data` DATE, IN `p_godzina` TIME)   BEGIN
    INSERT INTO Rezerwacje (klient_ID, pracownik_ID, usługa_ID, data, godzina, status)
    VALUES (p_klient_ID, p_pracownik_ID, p_usluga_ID, p_data, p_godzina, 'Zarezerwowana');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `najczesciej_rezerwowana_usluga` ()   BEGIN
    SELECT u.nazwa, COUNT(r.rezerwacja_ID) AS liczba_rezerwacji
    FROM Usługi u
    JOIN Rezerwacje r ON u.usługa_ID = r.usługa_ID
    GROUP BY u.nazwa
    ORDER BY liczba_rezerwacji DESC
    LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `najwiecej_wydal_klient` ()   BEGIN
    SELECT k.imię, k.nazwisko, SUM(u.cena) AS wydane_pieniadze
    FROM Klienci k
    JOIN Rezerwacje r ON k.klient_ID = r.klient_ID
    JOIN Usługi u ON r.usługa_ID = u.usługa_ID
    GROUP BY k.imię, k.nazwisko
    ORDER BY wydane_pieniadze DESC
    LIMIT 1;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `TotalRevenue` (`start_date` DATE, `end_date` DATE) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE total DECIMAL(10, 2);

    SELECT SUM(cena)
    INTO total
    FROM Rezerwacje r
    JOIN Usługi u ON r.usługa_ID = u.usługa_ID
    WHERE r.data BETWEEN start_date AND end_date;

    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `klienci`
--

CREATE TABLE `klienci` (
  `klient_ID` int(20) NOT NULL,
  `imię` varchar(50) NOT NULL,
  `nazwisko` varchar(50) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `telefon` varchar(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `klienci`
--

INSERT INTO `klienci` (`klient_ID`, `imię`, `nazwisko`, `email`, `telefon`) VALUES
(1, 'Anna', 'Kowalska', 'anna@example.com', '123456789'),
(2, 'Jan', 'Nowak', 'nowak@example.com', '987654321'),
(3, 'Marta', 'Wiśniewska', 'marta.wisniewska4@example.com', '564738291'),
(4, 'Krzysztof', 'Kowalczyk', 'krzysztof.kowalczyk@example.com', '123987654'),
(5, 'Agnieszka', 'Zielińska', 'agnieszkaa@example.com', '321456987'),
(6, 'Barbara', 'Wójcik', 'barbara.wojcik@example.com', '456789123'),
(7, 'Tomasz', 'Lewandowski', 'lewandowski@example.com', '987123654'),
(8, 'Piotr', 'Kamiński', 'piotr.kaminski12@example.com', '321654987'),
(9, 'Magdalena', 'Zając', 'magdalena.zajac@example.com', '654987321'),
(10, 'Paweł', 'Król', 'pawel@example.com', '789123456'),
(11, 'Natalia', 'Piotrowska', 'natalia.piotrowska@example.com', '654321789'),
(12, 'Łukasz', 'Wesołowski', 'wesolowski@example.com', '789456123'),
(13, 'Monika', 'Kaczmarek', 'monika.kaczmarek@example.com', '987654321'),
(14, 'Rafał', 'Kozłowski', 'rafal31@example.com', '654789123'),
(15, 'Izabela', 'Ostrowska', 'ostrowska1@example.com', '321987654');

--
-- Wyzwalacze `klienci`
--
DELIMITER $$
CREATE TRIGGER `after_klienci_delete` AFTER DELETE ON `klienci` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('DELETE Klienci: id=', OLD.klient_ID, ' imię=', OLD.imię, ' nazwisko=', OLD.nazwisko), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_klienci_update` AFTER UPDATE ON `klienci` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('AFTER UPDATE Klienci: id=', NEW.klient_ID, ' imię=', NEW.imię, ' nazwisko=', NEW.nazwisko), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_klienci_insert` BEFORE INSERT ON `klienci` FOR EACH ROW BEGIN
    -- Sprawdzenie, czy email jest unikalny
    IF EXISTS (SELECT 1 FROM Klienci WHERE email = NEW.email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email już istnieje w bazie danych';
    END IF;

    -- Sprawdzenie, czy email jest poprawny (prosta walidacja)
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Niepoprawny format adresu email';
    END IF;

    -- Logowanie operacji walidacji
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('VALIDATE Klienci: email=', NEW.email), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_klienci_update` BEFORE UPDATE ON `klienci` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('BEFORE UPDATE Klienci: id=', OLD.klient_ID, ' imię=', OLD.imię, ' nazwisko=', OLD.nazwisko), NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `logi`
--

CREATE TABLE `logi` (
  `log_ID` int(6) NOT NULL,
  `operacja` varchar(50) DEFAULT NULL,
  `czas` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `pracownicy`
--

CREATE TABLE `pracownicy` (
  `pracownik_ID` int(20) NOT NULL,
  `imię` varchar(50) NOT NULL,
  `nazwisko` varchar(50) NOT NULL,
  `specjalizacja` varchar(100) DEFAULT NULL,
  `telefon` varchar(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pracownicy`
--

INSERT INTO `pracownicy` (`pracownik_ID`, `imię`, `nazwisko`, `specjalizacja`, `telefon`) VALUES
(1, 'Piotr', 'Wiśniewski', 'Fryzjer', '555123123'),
(2, 'Ewa', 'Szymańska', 'Kosmetolog', '555321321'),
(3, 'Paweł', 'Dąbrowski', 'Masażysta', '555987987'),
(4, 'Zofia', 'Kwiatkowska', 'Manikiurzystka', '555654654'),
(5, 'Tomasz', 'Mazur', 'Stylista', '555789789'),
(6, 'Michał', 'Rutkowski', 'Stylista', '555456456'),
(7, 'Anna', 'Górska', 'Kosmetolog', '555789456');

--
-- Wyzwalacze `pracownicy`
--
DELIMITER $$
CREATE TRIGGER `after_pracownicy_delete` AFTER DELETE ON `pracownicy` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('DELETE Pracownicy: id=', OLD.pracownik_ID, ' imię=', OLD.imię, ' nazwisko=', OLD.nazwisko), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_pracownicy_insert` AFTER INSERT ON `pracownicy` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('AFTER INSERT Pracownicy: id=', NEW.pracownik_ID, ' imię=', NEW.imię, ' nazwisko=', NEW.nazwisko), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_pracownicy_update` AFTER UPDATE ON `pracownicy` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('AFTER UPDATE Pracownicy: id=', NEW.pracownik_ID, ' imię=', NEW.imię, ' nazwisko=', NEW.nazwisko), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_pracownicy_insert` BEFORE INSERT ON `pracownicy` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('BEFORE INSERT Pracownicy: imię=', NEW.imię, ' nazwisko=', NEW.nazwisko), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_pracownicy_update` BEFORE UPDATE ON `pracownicy` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('BEFORE UPDATE Pracownicy: id=', OLD.pracownik_ID, ' imię=', OLD.imię, ' nazwisko=', OLD.nazwisko), NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `rezerwacje`
--

CREATE TABLE `rezerwacje` (
  `rezerwacja_ID` int(20) NOT NULL,
  `klient_ID` int(20) NOT NULL,
  `pracownik_ID` int(20) NOT NULL,
  `usługa_ID` int(20) NOT NULL,
  `data` date DEFAULT NULL,
  `godzina` time DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rezerwacje`
--

INSERT INTO `rezerwacje` (`rezerwacja_ID`, `klient_ID`, `pracownik_ID`, `usługa_ID`, `data`, `godzina`, `status`) VALUES
(1, 1, 1, 1, '2024-05-20', '10:00:00', 'Zarezerwowana'),
(2, 2, 2, 2, '2024-05-21', '12:45:00', 'Zarezerwowana'),
(3, 3, 3, 3, '2024-05-22', '14:00:00', 'Zarezerwowana'),
(4, 4, 4, 4, '2024-05-23', '13:00:00', 'Zarezerwowana'),
(5, 5, 5, 5, '2024-06-24', '18:00:00', 'Zarezerwowana'),
(6, 6, 1, 1, '2024-05-25', '09:00:00', 'Zarezerwowana'),
(7, 1, 2, 2, '2024-06-26', '11:40:00', 'Zarezerwowana'),
(8, 8, 3, 3, '2024-05-27', '13:00:00', 'Zarezerwowana'),
(9, 9, 1, 1, '2024-05-28', '15:00:00', 'Zarezerwowana'),
(10, 10, 2, 2, '2024-05-29', '17:00:00', 'Zarezerwowana'),
(11, 3, 6, 6, '2024-05-30', '10:05:00', 'Zarezerwowana'),
(12, 3, 7, 7, '2024-05-31', '12:00:00', 'Zarezerwowana'),
(13, 13, 1, 1, '2024-06-01', '14:35:00', 'Zarezerwowana'),
(14, 14, 2, 2, '2024-06-02', '16:00:00', 'Zarezerwowana'),
(15, 15, 3, 3, '2024-06-03', '18:00:00', 'Zarezerwowana');

--
-- Wyzwalacze `rezerwacje`
--
DELIMITER $$
CREATE TRIGGER `after_rezerwacje_delete` AFTER DELETE ON `rezerwacje` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES ('Usunięto rekord z tabeli rezerwacje', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_rezerwacje_insert` AFTER INSERT ON `rezerwacje` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES ('Dodano rekord do tabeli rezerwacje', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_rezerwacje_update` AFTER UPDATE ON `rezerwacje` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('AFTER UPDATE Rezerwacje: id=', NEW.rezerwacja_ID, ' klient_id=', NEW.klient_ID, ' pracownik_id=', NEW.pracownik_ID, ' usługa_id=', NEW.usługa_ID, ' data=', NEW.data, ' godzina=', NEW.godzina), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_rezerwacje_update` BEFORE UPDATE ON `rezerwacje` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('BEFORE UPDATE Rezerwacje: id=', OLD.rezerwacja_ID, ' klient_id=', OLD.klient_ID, ' pracownik_id=', OLD.pracownik_ID, ' usługa_id=', OLD.usługa_ID, ' data=', OLD.data, ' godzina=', OLD.godzina), NOW());
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `usługi`
--

CREATE TABLE `usługi` (
  `usługa_ID` int(20) NOT NULL,
  `nazwa` varchar(100) NOT NULL,
  `opis` text DEFAULT NULL,
  `cena` decimal(6,2) DEFAULT NULL,
  `czas_trwania` int(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `usługi`
--

INSERT INTO `usługi` (`usługa_ID`, `nazwa`, `opis`, `cena`, `czas_trwania`) VALUES
(1, 'Strzyżenie', 'Profesjonalne strzyżenie włosów', 50.99, 30),
(2, 'Koloryzacja', 'Farbowanie włosów', 120.00, 90),
(3, 'Manicure', 'Pełny manicure', 45.00, 60),
(4, 'Masaż relaksacyjny', 'Masaż ciała', 100.00, 60),
(5, 'Makijaż', 'Profesjonalny makijaż', 80.00, 45),
(6, 'Pedicure', 'Pełny pedicure', 71.47, 60),
(7, 'Strzyżenie męskie', 'Strzyżenie dla mężczyzn', 45.11, 30);

--
-- Wyzwalacze `usługi`
--
DELIMITER $$
CREATE TRIGGER `after_uslugi_delete` AFTER DELETE ON `usługi` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('DELETE Usługi: id=', OLD.usługa_ID, ' nazwa=', OLD.nazwa), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_uslugi_insert` AFTER INSERT ON `usługi` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('AFTER INSERT Usługi: id=', NEW.usługa_ID, ' nazwa=', NEW.nazwa), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_uslugi_update` AFTER UPDATE ON `usługi` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('AFTER UPDATE Usługi: id=', NEW.usługa_ID, ' nazwa=', NEW.nazwa), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_uslugi_insert` BEFORE INSERT ON `usługi` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('BEFORE INSERT Usługi: nazwa=', NEW.nazwa), NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_uslugi_update` BEFORE UPDATE ON `usługi` FOR EACH ROW BEGIN
    INSERT INTO Logi (operacja, czas)
    VALUES (CONCAT('BEFORE UPDATE Usługi: id=', OLD.usługa_ID, ' nazwa=', OLD.nazwa), NOW());
END
$$
DELIMITER ;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `klienci`
--
ALTER TABLE `klienci`
  ADD PRIMARY KEY (`klient_ID`),
  ADD KEY `idx_nazwisko` (`nazwisko`);

--
-- Indeksy dla tabeli `logi`
--
ALTER TABLE `logi`
  ADD PRIMARY KEY (`log_ID`);

--
-- Indeksy dla tabeli `pracownicy`
--
ALTER TABLE `pracownicy`
  ADD PRIMARY KEY (`pracownik_ID`);

--
-- Indeksy dla tabeli `rezerwacje`
--
ALTER TABLE `rezerwacje`
  ADD PRIMARY KEY (`rezerwacja_ID`),
  ADD KEY `klient_ID` (`klient_ID`),
  ADD KEY `usługa_ID` (`usługa_ID`),
  ADD KEY `idx_data` (`data`),
  ADD KEY `idx_pracownik_data` (`pracownik_ID`,`data`);

--
-- Indeksy dla tabeli `usługi`
--
ALTER TABLE `usługi`
  ADD PRIMARY KEY (`usługa_ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `klienci`
--
ALTER TABLE `klienci`
  MODIFY `klient_ID` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `logi`
--
ALTER TABLE `logi`
  MODIFY `log_ID` int(6) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pracownicy`
--
ALTER TABLE `pracownicy`
  MODIFY `pracownik_ID` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `rezerwacje`
--
ALTER TABLE `rezerwacje`
  MODIFY `rezerwacja_ID` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `usługi`
--
ALTER TABLE `usługi`
  MODIFY `usługa_ID` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `rezerwacje`
--
ALTER TABLE `rezerwacje`
  ADD CONSTRAINT `rezerwacje_ibfk_1` FOREIGN KEY (`klient_ID`) REFERENCES `klienci` (`klient_ID`),
  ADD CONSTRAINT `rezerwacje_ibfk_2` FOREIGN KEY (`pracownik_ID`) REFERENCES `pracownicy` (`pracownik_ID`),
  ADD CONSTRAINT `rezerwacje_ibfk_3` FOREIGN KEY (`usługa_ID`) REFERENCES `usługi` (`usługa_ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
