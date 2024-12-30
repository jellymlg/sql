INSERT INTO Sockets(SocketId, socketName) VALUES (1, 'LGA 1155');
INSERT INTO Sockets(SocketId, socketName) VALUES (2, 'LGA 1150');
INSERT INTO Sockets(SocketId, socketName) VALUES (3, 'LGA 1151 v1');
INSERT INTO Sockets(SocketId, socketName) VALUES (4, 'LGA 1151 v2');
INSERT INTO Sockets(SocketId, socketName) VALUES (5, 'LGA 1200');
INSERT INTO Sockets(SocketId, socketName) VALUES (6, 'LGA 1700');
INSERT INTO Sockets(SocketId, socketName) VALUES (7, 'LGA 1851');
INSERT INTO Sockets(SocketId, socketName) VALUES (8, 'LGA 2011');
INSERT INTO Sockets(SocketId, socketName) VALUES (9, 'LGA 2011 v3');
INSERT INTO Sockets(SocketId, socketName) VALUES (10, 'LGA 2066');
INSERT INTO Sockets(SocketId, socketName) VALUES (11, 'AM3/AM3+');
INSERT INTO Sockets(SocketId, socketName) VALUES (12, 'AM4');
INSERT INTO Sockets(SocketId, socketName) VALUES (13, 'AM5');
INSERT INTO Sockets(SocketId, socketName) VALUES (14, 'FM2/FM2+');
INSERT INTO Sockets(SocketId, socketName) VALUES (15, 'TR4');

INSERT INTO PCI(PCIId, version, width) VALUES (1, 1, 1);
INSERT INTO PCI(PCIId, version, width) VALUES (2, 1, 4);
INSERT INTO PCI(PCIId, version, width) VALUES (3, 1, 8);
INSERT INTO PCI(PCIId, version, width) VALUES (4, 1, 16);
INSERT INTO PCI(PCIId, version, width) VALUES (5, 2, 1);
INSERT INTO PCI(PCIId, version, width) VALUES (6, 2, 4);
INSERT INTO PCI(PCIId, version, width) VALUES (7, 2, 8);
INSERT INTO PCI(PCIId, version, width) VALUES (8, 2, 16);
INSERT INTO PCI(PCIId, version, width) VALUES (9, 3, 1);
INSERT INTO PCI(PCIId, version, width) VALUES (10, 3, 4);
INSERT INTO PCI(PCIId, version, width) VALUES (11, 3, 8);
INSERT INTO PCI(PCIId, version, width) VALUES (12, 3, 16);
INSERT INTO PCI(PCIId, version, width) VALUES (13, 4, 1);
INSERT INTO PCI(PCIId, version, width) VALUES (14, 4, 4);
INSERT INTO PCI(PCIId, version, width) VALUES (15, 4, 8);
INSERT INTO PCI(PCIId, version, width) VALUES (16, 4, 16);
INSERT INTO PCI(PCIId, version, width) VALUES (17, 5, 1);
INSERT INTO PCI(PCIId, version, width) VALUES (18, 5, 4);
INSERT INTO PCI(PCIId, version, width) VALUES (19, 5, 8);
INSERT INTO PCI(PCIId, version, width) VALUES (20, 5, 16);
INSERT INTO PCI(PCIId, version, width) VALUES (21, 6, 1);
INSERT INTO PCI(PCIId, version, width) VALUES (22, 6, 4);
INSERT INTO PCI(PCIId, version, width) VALUES (23, 6, 8);
INSERT INTO PCI(PCIId, version, width) VALUES (24, 6, 16);

INSERT INTO Brands(brandId, brandName) VALUES (1, 'Intel');
INSERT INTO Brands(brandId, brandName) VALUES (2, 'AMD');
INSERT INTO Brands(brandId, brandName) VALUES (3, 'ASUS');
INSERT INTO Brands(brandId, brandName) VALUES (4, 'ASRock');
INSERT INTO Brands(brandId, brandName) VALUES (5, 'GiGABYTE');
INSERT INTO Brands(brandId, brandName) VALUES (6, 'MSI');

INSERT INTO RAMType(RAMTypeId, RAMTypeName) VALUES (1, 'DDR1');
INSERT INTO RAMType(RAMTypeId, RAMTypeName) VALUES (2, 'DDR2');
INSERT INTO RAMType(RAMTypeId, RAMTypeName) VALUES (3, 'DDR3');
INSERT INTO RAMType(RAMTypeId, RAMTypeName) VALUES (4, 'DDR4');
INSERT INTO RAMType(RAMTypeId, RAMTypeName) VALUES (5, 'DDR5');

INSERT INTO FormFactor(formId, formName, widthMM, heightMM) VALUES (1, 'Extended-ATX', 305, 330);
INSERT INTO FormFactor(formId, formName, widthMM, heightMM) VALUES (2, 'Standard-ATX', 305, 244);
INSERT INTO FormFactor(formId, formName, widthMM, heightMM) VALUES (3, 'Micro-ATX', 244, 244);
INSERT INTO FormFactor(formId, formName, widthMM, heightMM) VALUES (4, 'Mini-ITX', 170, 170);

INSERT INTO PSUQuality(PSUQualityId, qualityName, efficiency) VALUES (1, 'BRONZE', 85);
INSERT INTO PSUQuality(PSUQualityId, qualityName, efficiency) VALUES (2, 'SILVER', 88);
INSERT INTO PSUQuality(PSUQualityId, qualityName, efficiency) VALUES (3, 'GOLD', 90);
INSERT INTO PSUQuality(PSUQualityId, qualityName, efficiency) VALUES (4, 'PLATINUM', 92);
INSERT INTO PSUQuality(PSUQualityId, qualityName, efficiency) VALUES (5, 'TITANIUM', 94);

INSERT INTO Supplier(supplierId, supplierName) VALUES (1, 'iPon');
INSERT INTO Supplier(supplierId, supplierName) VALUES (2, 'AQUA');

INSERT INTO ProductType(productTypeId, productName) VALUES (1, 'CPU');
INSERT INTO ProductType(productTypeId, productName) VALUES (2, 'RAM');
INSERT INTO ProductType(productTypeId, productName) VALUES (3, 'MOBO');
INSERT INTO ProductType(productTypeId, productName) VALUES (4, 'COOLER');
INSERT INTO ProductType(productTypeId, productName) VALUES (5, 'GPU');
INSERT INTO ProductType(productTypeId, productName) VALUES (6, 'CASE');
INSERT INTO ProductType(productTypeId, productName) VALUES (7, 'PSU');