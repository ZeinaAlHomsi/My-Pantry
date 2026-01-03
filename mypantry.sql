-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 03, 2026 at 09:05 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mypantry`
--

-- --------------------------------------------------------

--
-- Table structure for table `pantry_items`
--

CREATE TABLE `pantry_items` (
  `id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `amount` double NOT NULL,
  `category` int(11) NOT NULL,
  `expiryDate` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pantry_items`
--

INSERT INTO `pantry_items` (`id`, `name`, `amount`, `category`, `expiryDate`) VALUES
('1767284424607', 'Tomato', 9, 1, 1769896800000),
('1767284536171', 'Banana', 4, 0, 1767132000000),
('1767284602239', 'Almond', 250, 2, 1774904400000),
('1767395081962', 'Potatoes', 7, 1, 1769032800000);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pantry_items`
--
ALTER TABLE `pantry_items`
  ADD PRIMARY KEY (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
