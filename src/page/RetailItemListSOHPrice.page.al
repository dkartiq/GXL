/*Change Log
    PS-2493: New page - a copy of standard LS "Retail Item List" to add price/SOH
*/
page 50034 "GXL Retail Item List-SOHPrice"
{

    ApplicationArea = All;
    Caption = 'Retail Item List - SOH/Price';
    CardPageID = "LSC Retail Item Card";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Item,Inventory,History,Pricing,Printing,Category9_caption,Category10_caption';
    SourceTable = Item;
    UsageCategory = Lists;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(SOH; SOH)
                {
                    ApplicationArea = All;
                    Caption = 'SOH';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field(UnitPrice; UnitPrice)
                {
                    ApplicationArea = All;
                    Caption = 'Unit Price';
                    Editable = false;
                }
                field("GXL Item Category Description"; GXL_strText[1])
                {
                    ApplicationArea = All;
                    Caption = 'Item Category Description';
                    Editable = false;
                }
                field("GXL Retail Product Code Description"; GXL_strText[2])
                {
                    ApplicationArea = All;
                    Caption = 'Retail Product Group Description';
                    Editable = false;
                }
                field("GXL Sub Category3 Description"; GXL_strText[3])
                {
                    ApplicationArea = All;
                    Caption = 'Sub Category3 Description';
                    Editable = false;
                }

                field("GXL Sub Category4 Description"; GXL_strText[4])
                {
                    ApplicationArea = All;
                    Caption = 'Sub Category4 Description';
                    Editable = false;
                }
                field(BarcodeNo; BarcodeNo)
                {
                    ApplicationArea = All;
                    Caption = 'Barcode No.';
                }
                field("Division Code"; Rec."LSC Division Code")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Retail Product Code"; Rec."LSC Retail Product Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Category Code"; Rec."GXL Category Code")
                {
                    ApplicationArea = All;
                }
                field("GXLSub Category3 Code"; Rec."GXL Sub Category3 Code")
                {
                    ApplicationArea = All;
                }
                field("GXLSub Category4 Code"; Rec."GXL Sub Category4 Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Costing Method"; Rec."Costing Method")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sales Unit of Measure"; Rec."Sales Unit of Measure")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Standard Cost"; Rec."Standard Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Last Direct Cost"; Rec."Last Direct Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Price/Profit Calculation"; Rec."Price/Profit Calculation")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Profit %"; Rec."Profit %")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Inventory Posting Group"; Rec."Inventory Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item Disc. Group"; Rec."Item Disc. Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Overhead Rate"; Rec."Overhead Rate")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Stockkeeping Unit Exists"; Rec."Stockkeeping Unit Exists")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("GXLSignage 1"; Rec."GXL Signage 1")
                {
                    ApplicationArea = All;
                }
                field("Created From Nonstock Item"; Rec."Created From Nonstock Item")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Substitutes Exist"; Rec."Substitutes Exist")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Tariff No."; Rec."Tariff No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Replenishment Calculation Type"; Rec."LSC Replen. Calculation Type")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Exclude from Replenishment"; Rec."LSC Exclude from Replenishment")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("GXL Supplier Number"; Rec."GXL Supplier Number")
                {
                    ApplicationArea = All;
                }
                field("GXL Distributor Number"; Rec."GXL Distributor Number")
                {
                    ApplicationArea = All;
                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part(Control1906840407; "Item Planning FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = FIELD("No.");
            }
            part(Control1901796907; "Item Warehouse FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = FIELD("No.");
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Control1901377607; MyNotes)
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Availability")
            {
                Caption = '&Availability';
                action("Items b&y Location")
                {
                    AccessByPermission = TableData Location = R;
                    ApplicationArea = All;
                    Caption = 'Items b&y Location';
                    Image = ItemAvailbyLoc;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        ItemsByLocation_l: Page "Items by Location";
                    begin
                        ItemsByLocation_l.SetRecord(Rec);
                        ItemsByLocation_l.Run;
                    end;
                }
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    Image = ItemAvailability;
                    action("&Period")
                    {
                        ApplicationArea = All;
                        Caption = '&Period';
                        Image = Period;
                        // >> Upgrade
                        //RunObject = Page "Retail Item Avail. by Periods";
                        RunObject = Page "LSC Retail Item Avail.-Periods";
                        // << Upgrade
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                    action("&Variant")
                    {
                        ApplicationArea = All;
                        Caption = '&Variant';
                        Image = ItemVariant;
                        // >> Upgrade
                        //RunObject = Page "Retail Item Avail. by Variant";
                        RunObject = Page "LSC Retail Item Avail.-Variant";
                        // << Upgrade
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                    action("&Location")
                    {
                        ApplicationArea = All;
                        Caption = '&Location';
                        Image = Warehouse;
                        //>>upgrade
                        //RunObject = Page "Retail Item Avail. by Loc.";
                        RunObject = Page "LSC Retail Item Avail.-Loc.";
                        //<< upgrade
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                      "Variant Filter" = FIELD("Variant Filter"),
                                      "Bin Filter" = FIELD("Bin Filter");
                    }
                    action("BOM Level")
                    {
                        ApplicationArea = All;
                        Caption = 'BOM Level';
                        Image = BOMLevel;

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec, ItemAvailFormsMgt.ByBOM);
                        end;
                    }
                }
            }
            group("&Master Data")
            {
                Caption = '&Master Data';
                action("&Units of Measure")
                {
                    ApplicationArea = All;
                    Caption = '&Units of Measure';
                    Image = UnitOfMeasure;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Units of Measure";
                    RunPageLink = "Item No." = FIELD("No.");
                }
                group("&Variants")
                {
                    Caption = '&Variants';
                    Image = ItemVariant;
                    action("Page Variant")
                    {
                        ApplicationArea = All;
                        Caption = 'Va&riants';
                        Image = ItemVariant;
                        //PromotedCategory = Category4;

                        trigger OnAction()
                        var
                            VariantWorksheet: Page "LSC Variant Worksheet";
                            ItemVariant: Record "Item Variant";
                        begin
                            if Rec."LSC Variant Framework Code" <> '' then begin
                                Clear(VariantWorksheet);
                                VariantWorksheet.LoadForm(Rec."No.");
                                VariantWorksheet.Run;
                            end
                            else begin
                                ItemVariant.SetRange("Item No.", Rec."No.");
                                PAGE.Run(5401, ItemVariant);
                            end;
                        end;
                    }
                    action("Page Item Variant Framework")
                    {
                        ApplicationArea = All;
                        Caption = 'Variant &Framework';
                        Image = Ranges;
                        //PromotedCategory = Category4;
                        RunObject = Page "LSC Item Variant Framework";
                        RunPageLink = Item = FIELD("No.");
                    }
                    action("Page Collection Matrix")
                    {
                        ApplicationArea = All;
                        Caption = 'C&ollection';
                        Image = Group;
                        RunObject = Page "LSC Collection Matrix";
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                    action("Page Item Dimension Pattern")
                    {
                        ApplicationArea = All;
                        Caption = '&Dimension Pattern';
                        Image = CodesList;
                        //>>upgrade
                        //RunObject = Page "Item Dimension Pattern Link";
                        RunObject = Page "LSC Item Dimens. Pattern Link";
                        //<<upgrade
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.", "Dimension 1", "Group Type", Group);
                    }
                }
                action("&Dimensions")
                {
                    ApplicationArea = All;
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(27),
                                  "No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                }
                action("&Extended Texts")
                {
                    ApplicationArea = All;
                    Caption = '&Extended Texts';
                    Image = Text;
                    RunObject = Page "Extended Text List";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Table Name", "No.", "Language Code", "All Language Codes", "Starting Date", "Ending Date");
                }
                action("&Translations")
                {
                    ApplicationArea = All;
                    Caption = '&Translations';
                    Image = Translations;
                    RunObject = Page "Item Translations";
                    RunPageLink = "Item No." = FIELD("No."),
                                  "Variant Code" = CONST('');
                }
                action("&Picture")
                {
                    ApplicationArea = All;
                    Caption = '&Picture';
                    Image = Picture;
                    //PromotedCategory = Category4;
                    RunObject = Page "Item Picture";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                  "Location Filter" = FIELD("Location Filter"),
                                  "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                                  "Variant Filter" = FIELD("Variant Filter"),
                                  "Bin Filter" = FIELD("Bin Filter");
                }
                action("&Barcode List")
                {
                    ApplicationArea = All;
                    Caption = '&Barcode List';
                    Image = BarCode;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "LSc Item Barcodes";
                    RunPageLink = "Item No." = FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+B';
                }
                group("&Labels and Printing")
                {
                    Caption = '&Labels & Printing Setup';
                    Image = Print;
                    action("Shelf La&bel Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'Shelf La&bel Setup';
                        Image = SetupList;
                        RunObject = Page "LSC Shelf Label Setup";
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                    action("&Item Label Setup")
                    {
                        ApplicationArea = All;
                        Caption = '&Item Label Setup';
                        Image = PriceWorksheet;
                        RunObject = Page "LSC Item Label Setup";
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                    separator(Action1100409037)
                    {
                    }
                    action("POS Terminal &Receipt Text")
                    {
                        ApplicationArea = All;
                        Caption = 'POS Terminal &Receipt Text';
                        Image = Text;
                        RunObject = Page "LSC Item POS Text List";
                        RunPageLink = "Item No." = FIELD("No."),
                                      "Text Type" = CONST("Receipt Text");
                    }
                    action("POS Terminal &Sales Text")
                    {
                        ApplicationArea = All;
                        Caption = 'POS Terminal &Sales Text';
                        Image = Description;
                        RunObject = Page "LSC Item POS Text List";
                        RunPageLink = "Item No." = FIELD("No."),
                                      "Text Type" = CONST("Sales Text");
                        Visible = false;
                    }
                    action("POS Terminal &Price Lookup Txt.")
                    {
                        ApplicationArea = All;
                        Caption = 'POS Terminal &Price Lookup Txt.';
                        Image = Price;
                        RunObject = Page "LSC Item POS Text List";
                        RunPageLink = "Item No." = FIELD("No."),
                                      "Text Type" = CONST("Price Lookup Text");
                        Visible = false;
                    }
                    separator(Action1100409033)
                    {
                    }
                    action("E&xtra Print Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'E&xtra Print Setup';
                        Image = PrintInstallment;
                        RunObject = Page "LSC POS Extra Print Setup";
                        RunPageLink = "Table No." = CONST(27),
                                      Key = FIELD("No.");
                    }
                    action("GS1 DataBar Barcodes with Serial Nos")
                    {
                        ApplicationArea = All;
                        Caption = 'GS1 DataBar Barcodes with Serial Nos';
                        Image = BarCode;

                        trigger OnAction()
                        var
                            ItemLedgerEntryLoc: Record "Item Ledger Entry";
                        begin
                            ItemLedgerEntryLoc.Reset;
                            ItemLedgerEntryLoc.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
                            ItemLedgerEntryLoc.SetRange("Item No.", Rec."No.");
                            //>>Upgrade
                            // REPORT.RunModal(REPORT::"LSC GS1 DataBar Barcode From ILE", true, false, ItemLedgerEntryLoc);
                            REPORT.RunModal(REPORT::"LSC GS1DataBar Barcode FromILE", true, false, ItemLedgerEntryLoc);
                            //<<upgrade
                        end;
                    }
                }
                action("&Images")
                {
                    ApplicationArea = All;
                    Caption = '&Images';
                    Image = Picture;
                    RunPageMode = View;

                    trigger OnAction()
                    var
                        RecRef: RecordRef;
                        //>> upgrade
                        // BOUtils_l: Codeunit " BO Utils";
                        BOUtils_l: Codeunit "LSC BO Utils";
                        ImageTableLink: Record "LSC Retail Image Link";
                        ImageLinkPage: Page "LSC Retail Image Link List";
                    //upgrade
                    begin
                        RecRef.GetTable(Rec);
                        // >> Upgrade
                        // BOUtils_l.DisplayRetailImage(RecRef);
                        RecRef.FILTERGROUP(2);
                        ImageTableLink.SETRANGE("Record Id", FORMAT(RecRef.RECORDID));
                        RecRef.FILTERGROUP(0);
                        ImageTableLink.SETCURRENTKEY("Display Order");
                        ImageLinkPage.SETTABLEVIEW(ImageTableLink);
                        ImageLinkPage.LOOKUPMODE(TRUE);
                        ImageLinkPage.RUNMODAL;
                        // << Upgrade
                    end;
                }
                action("Page Item HTML Web")
                {
                    ApplicationArea = All;
                    Caption = 'Item &HTML';
                    Image = ElectronicDoc;
                    RunObject = Page "LSC Item HTML";
                    RunPageLink = "Item No." = FIELD("No.");
                    Visible = VisibleInWebClient;
                }
                action("Item &HTML")
                {
                    ApplicationArea = All;
                    Caption = 'Item &HTML';
                    Image = ElectronicDoc;
                    RunObject = Page "LSC Item HTML";
                    RunPageLink = "Item No." = FIELD("No.");
                    Visible = VisibleInWinClient;
                }
                group("&Groups and Links")
                {
                    Caption = '&Groups and Links';
                    Image = ItemGroup;
                    action("&Attributes")
                    {
                        ApplicationArea = All;
                        Caption = '&Attributes';
                        Image = SetupList;
                        RunObject = Page "LSC Attribute Values";
                        RunPageLink = "Link Type" = CONST(Item),
                                      "Link Field 1" = FIELD(FILTER("No."));
                    }
                    action("Special &Groups")
                    {
                        ApplicationArea = All;
                        Caption = 'Special &Groups';
                        Image = IndustryGroups;
                        //PromotedCategory = Category4;
                        RunObject = Page "LSC Item/Special Group Links";
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                    action("&Events")
                    {
                        ApplicationArea = All;
                        Caption = '&Events';
                        Image = "Event";
                        RunObject = Page "LSC Item/Event Links";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                    }
                    action("Item S&tatus")
                    {
                        ApplicationArea = All;
                        Caption = 'Item S&tatus';
                        Image = Status;
                        RunObject = Page "LSC Item/Item Status Links";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.", "Variant Dimension 1 Code", "Variant Code", "Store Group Code", "Location Code", "Starting Date");
                    }
                    separator(Action1100409025)
                    {
                    }
                    action("&Linked Items")
                    {
                        ApplicationArea = All;
                        Caption = '&Linked Items';
                        Image = LinkWithExisting;
                        RunObject = Page "LSC Linked Items";
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                    action("&Where-Linked List")
                    {
                        ApplicationArea = All;
                        Caption = '&Where-Linked List';
                        Image = LinkAccount;
                        RunObject = Page "LSC Where-Linked List";
                        RunPageLink = "Linked Item No." = FIELD("No.");
                        RunPageView = SORTING("Linked Item No.", "Item No.");
                    }
                }
                action("&Replen. Control Data List")
                {
                    ApplicationArea = All;
                    Caption = '&Replen. Control Data List';
                    Image = ListPage;
                    //PromotedCategory = Category4;
                    //>>upgrade
                    //RunObject = Page "Replen. Control Data List";
                    RunObject = Page "LSC Replen. Control Data";
                    //<<upgrade
                }
            }
            group("&History")
            {
                Caption = '&History';
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    Image = Entries;
                    action("Ledger E&ntries")
                    {
                        ApplicationArea = All;
                        Caption = 'Ledger E&ntries';
                        Image = ItemLedger;
                        Promoted = true;
                        PromotedCategory = Category6;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                        ShortCutKey = 'Ctrl+F7';
                    }
                    action("&Reservation Entries")
                    {
                        ApplicationArea = All;
                        Caption = '&Reservation Entries';
                        Image = ReservationLedger;
                        RunObject = Page "Reservation Entries";
                        RunPageLink = "Reservation Status" = CONST(Reservation),
                                      "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.", "Variant Code", "Location Code", "Reservation Status");
                    }
                    action("&Phys. Inventory Ledger Entries")
                    {
                        ApplicationArea = All;
                        Caption = '&Phys. Inventory Ledger Entries';
                        Image = PhysicalInventoryLedger;
                        RunObject = Page "Phys. Inventory Ledger Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                    }
                    action("&Value Entries")
                    {
                        ApplicationArea = All;
                        Caption = '&Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                    }
                    action("Item &Tracking Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Item &Tracking Entries';
                        Image = ItemTrackingLedger;
                        RunObject = Page "Item Tracking Entries";
                        RunPageLink = "Item No." = FIELD("No.");
                        RunPageView = SORTING("Item No.");
                    }
                }
                group("&Statistics")
                {
                    Caption = '&Statistics';
                    Image = Statistics;
                    action("Page Statistics")
                    {
                        ApplicationArea = All;
                        Caption = '&Statistics';
                        Image = Statistics;
                        Promoted = true;
                        PromotedCategory = Category4;
                        ShortCutKey = 'Shift+Ctrl+J';

                        trigger OnAction()
                        var
                            ItemStatistics: Page "Item Statistics";
                        begin
                            ItemStatistics.SetItem(Rec);
                            ItemStatistics.Run;
                        end;
                    }
                    action("Page Item Entry Statistics")
                    {
                        ApplicationArea = All;
                        Caption = 'Entr&y Statistics';
                        Image = EntryStatistics;
                        //PromotedCategory = Category4;
                        RunObject = Page "Item Entry Statistics";
                        RunPageLink = "No." = FIELD("No."),
                                      "Date Filter" = FIELD("Date Filter"),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter");
                    }
                    action("Page Retail Item Turnove")
                    {
                        ApplicationArea = All;
                        Caption = 'T&urneover';
                        Image = Turnover;
                        //PromotedCategory = Category4;
                        RunObject = Page "LSC Retail Item Turnover";
                        RunPageLink = "No." = FIELD("No."),
                                      "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                      "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                      "Location Filter" = FIELD("Location Filter"),
                                      "Drop Shipment Filter" = FIELD("Drop Shipment Filter");
                    }
                    action("Page Sales by Periods")
                    {
                        ApplicationArea = All;
                        Caption = 'S&ales by Periods';
                        Image = Sales;
                        //PromotedCategory = Category4;
                        RunObject = Page "LSC Sales by Periods";
                        RunPageLink = "No." = FIELD("No.");
                    }
                }
                action("Co&mments")
                {
                    ApplicationArea = All;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("No.");
                }
                group("Price &History")
                {
                    Caption = 'Price &History';
                    Image = PriceAdjustment;
                    action("&Sales Price")
                    {
                        ApplicationArea = All;
                        Caption = '&Sales Price';
                        Image = SalesPrices;
                        RunObject = Page "LSC Price History";
                        RunPageLink = "Item No." = FIELD("No."),
                                      "Price Type" = CONST(Sale);
                    }
                    action("&Cost Price")
                    {
                        ApplicationArea = All;
                        Caption = '&Cost Price';
                        Image = Price;
                        RunObject = Page "LSC Cost Price History";
                        RunPageLink = "Price Type" = CONST(Cost),
                                      "Item No." = FIELD("No.");
                    }
                    action("&Vendor Price List")
                    {
                        ApplicationArea = All;
                        Caption = '&Vendor Price List';
                        Image = PriceWorksheet;
                        RunObject = Page "LSC Wholesale Price History";
                        RunPageLink = "Price Type" = CONST(Wholesale),
                                      "Item No." = FIELD("No.");
                    }
                }
            }
            group("&Purchases")
            {
                Caption = '&Purchases';
                action("Ven&dors")
                {
                    ApplicationArea = All;
                    Caption = 'Ven&dors';
                    Image = Vendor;
                    RunObject = Page "Item Vendor Catalog";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action("&Prices")
                {
                    ApplicationArea = All;
                    Caption = '&Prices';
                    Image = Price;
                    RunObject = Page "Purchase Prices";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action("&Line Discounts")
                {
                    ApplicationArea = All;
                    Caption = '&Line Discounts';
                    Image = LineDiscount;
                    RunObject = Page "Purchase Line Discounts";
                    RunPageLink = "Item No." = FIELD("No.");
                }
                separator(Action1100409084)
                {
                }
                action("&Orders")
                {
                    ApplicationArea = All;
                    Caption = '&Orders';
                    Image = Document;
                    RunObject = Page "Purchase Orders";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", Type, "No.");
                }
                action("&Return Orders")
                {
                    ApplicationArea = All;
                    Caption = '&Return Orders';
                    Image = ReturnOrder;
                    RunObject = Page "Purchase Return Orders";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", Type, "No.");
                }
            }
            group("S&ales")
            {
                Caption = 'S&ales';
                action(Action1100409080)
                {
                    ApplicationArea = All;
                    Caption = '&Prices';
                    Image = Price;
                    RunObject = Page "Sales Prices";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
                action(Action1100409079)
                {
                    ApplicationArea = All;
                    Caption = '&Line Discounts';
                    Image = LineDiscount;
                    RunObject = Page "Sales Line Discounts";
                    RunPageLink = Type = CONST(Item),
                                  Code = FIELD("No.");
                    RunPageView = SORTING(Type, Code);
                }
                separator(Action1100409078)
                {
                }
                action(Action1100409077)
                {
                    ApplicationArea = All;
                    Caption = '&Orders';
                    Image = Document;
                    RunObject = Page "Sales Orders";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", Type, "No.");
                }
                action(Action1100409076)
                {
                    ApplicationArea = All;
                    Caption = '&Return Orders';
                    Image = ReturnOrder;
                    RunObject = Page "Sales Return Orders";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", Type, "No.");
                }
                separator(Action1100409016)
                {
                }
                action("&Competitor Prices")
                {
                    ApplicationArea = All;
                    Caption = '&Competitor Prices';
                    Image = PriceWorksheet;
                    RunObject = Page "LSC Competitors Item Entry";
                    RunPageLink = "Item No." = FIELD("No.");
                }
                separator(Action1100409010)
                {
                }
                action("O&ffers")
                {
                    ApplicationArea = All;
                    Caption = 'O&ffers';
                    Image = Discount;
                    Promoted = true;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    var
                        TmpPerDiscPri: Record "LSC Periodic Discount" temporary;
                    begin
                        TmpPerDiscPri.Priority := 1;
                        TmpPerDiscPri."No." := Rec."No.";
                        TmpPerDiscPri.Insert;
                        PAGE.Run(Page::"LSC Periodic Disc. Priority", TmpPerDiscPri);
                    end;
                }
            }
            group("&Retail/POS")
            {
                Caption = '&Retail/POS';
                group("P&OS")
                {
                    Caption = 'P&OS';
                    Image = Calculate;
                    action("&Cross-selling")
                    {
                        ApplicationArea = All;
                        Caption = '&Cross-selling';
                        Image = Zones;
                        RunObject = Page "LSC Table Specific Infocodes";
                        RunPageLink = "Table ID" = CONST(27),
                                      Value = FIELD("No."),
                                      "Usage Category" = CONST("Cross-selling");
                    }
                    action("Infoco&des")
                    {
                        ApplicationArea = All;
                        Caption = 'Infoco&des';
                        Image = CodesList;
                        RunObject = Page "LSC Table Specific Infocodes";
                        RunPageLink = "Table ID" = CONST(27),
                                      Value = FIELD("No."),
                                      "Usage Category" = CONST(" ");
                    }
                    action("&Extra Print Setup")
                    {
                        ApplicationArea = All;
                        Caption = '&Extra Print Setup';
                        Image = PrintInstallment;
                        RunObject = Page "LSC POS Extra Print Setup";
                        RunPageLink = "Table No." = CONST(27),
                                      Key = FIELD("No.");
                    }
                    action("&POS Actions")
                    {
                        ApplicationArea = All;
                        Caption = '&POS Actions';
                        Image = View;
                        RunObject = Page "LSC POS Actions";
                        RunPageLink = "Data Trigger" = CONST(Item),
                                      "Data ID" = FIELD("No.");
                        RunPageView = SORTING("Data Trigger", "Data ID");
                    }
                }
                group("Store In&formation")
                {
                    Caption = 'Store In&formation';
                    Image = ItemTracking;
                    action("&Item Store Information")
                    {
                        ApplicationArea = All;
                        Caption = '&Item Store Information';
                        Image = Item;
                        RunObject = Page "LSC Item Store Information";
                        RunPageLink = "Item Filter" = FIELD("No.");
                        ShortCutKey = 'Shift+Ctrl+Y';
                    }
                    action("Location &Distribution")
                    {
                        ApplicationArea = All;
                        Caption = 'Location &Distribution';
                        Image = ItemTracking;
                        RunObject = Page "LSC Location Distribution";
                        RunPageLink = "Table ID" = CONST(27),
                                      Value = FIELD("No.");
                    }
                    action("Section &Locations")
                    {
                        ApplicationArea = All;
                        Caption = 'Section &Locations';
                        Image = Bin;
                        RunObject = Page "LSC Item Section Locations";
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                }
                group("Ac&tions")
                {
                    Caption = 'Ac&tions';
                    Image = Database;
                    action("&View &Preactions")
                    {
                        ApplicationArea = All;
                        Caption = '&View &Preactions';
                        Image = ViewPage;
                        RunObject = Page "LSC Preactions";
                        RunPageLink = "Table No." = CONST(27),
                                      Key = FIELD("No.");
                        RunPageView = SORTING("Table No.", "Entry No.");
                    }
                    action("&View Actions")
                    {
                        ApplicationArea = All;
                        Caption = '&View Actions';
                        Image = ViewOrder;
                        RunObject = Page "LSC Actions";
                        RunPageLink = "Table No." = CONST(27),
                                      Key = FIELD("No.");
                        RunPageView = SORTING("Table No.", "Entry No.");
                    }
                }
                action("Item in Dyn. Item Hierarchy")
                {
                    ApplicationArea = All;
                    Caption = 'Item in Dyn. Item Hierarchy';
                    Image = Hierarchy;

                    trigger OnAction()
                    var
                        ItemInHrchy: Page "LSC Item In Hierarchy";
                    begin
                        Clear(ItemInHrchy);
                        ItemInHrchy.SetItem(Rec."No.");
                        ItemInHrchy.Run;
                    end;
                }
            }
            group("Assembly/Production")
            {
                Caption = 'Assembly/Production';
                Image = Production;
                action(Structure)
                {
                    ApplicationArea = All;
                    Caption = 'Structure';
                    Image = Hierarchy;

                    trigger OnAction()
                    var
                        BOMStructure: Page "BOM Structure";
                    begin
                        BOMStructure.InitItem(Rec);
                        BOMStructure.Run;
                    end;
                }
                action("Cost Shares")
                {
                    ApplicationArea = All;
                    Caption = 'Cost Shares';
                    Image = CostBudget;

                    trigger OnAction()
                    var
                        BOMCostShares: Page "BOM Cost Shares";
                    begin
                        BOMCostShares.InitItem(Rec);
                        BOMCostShares.Run;
                    end;
                }
                group("Assemb&ly")
                {
                    Caption = 'Assemb&ly';
                    Image = AssemblyBOM;
                    action(AssemblyBOM)
                    {
                        ApplicationArea = All;
                        Caption = 'Assembly BOM';
                        Image = BOM;
                        RunObject = Page "Assembly BOM";
                        RunPageLink = "Parent Item No." = FIELD("No.");
                    }
                    action("Page Where-Used List")
                    {
                        ApplicationArea = All;
                        Caption = 'Where-Used';
                        Image = Track;
                        RunObject = Page "Where-Used List";
                        RunPageLink = Type = CONST(Item),
                                      "No." = FIELD("No.");
                        RunPageView = SORTING(Type, "No.");
                    }
                    action("Calc. Stan&dard Cost")
                    {
                        ApplicationArea = All;
                        Caption = 'Calc. Stan&dard Cost';
                        Image = CalculateCost;

                        trigger OnAction()
                        begin
                            Clear(CalculateStdCost);
                            CalculateStdCost.CalcItem(Rec."No.", true);
                        end;
                    }
                    action("Page Calc. Unit Price")
                    {
                        ApplicationArea = All;
                        Caption = 'Calc. Unit Price';
                        Image = SuggestItemPrice;

                        trigger OnAction()
                        begin
                            Clear(CalculateStdCost);
                            CalculateStdCost.CalcAssemblyItemPrice(Rec."No.");
                        end;
                    }
                }
                group(Production)
                {
                    Caption = 'Production';
                    Image = Production;
                    action("Page Production BOM")
                    {
                        ApplicationArea = All;
                        Caption = 'Production BOM';
                        Image = BOM;
                        RunObject = Page "Production BOM";
                        RunPageLink = "No." = FIELD("No.");
                    }
                    action("Page Where-Used")
                    {
                        ApplicationArea = All;
                        Caption = 'Where-Used';
                        Image = "Where-Used";

                        trigger OnAction()
                        var
                            ProdBOMWhereUsed: Page "Prod. BOM Where-Used";
                        begin
                            ProdBOMWhereUsed.SetItem(Rec, WorkDate);
                            ProdBOMWhereUsed.Run;
                        end;
                    }
                    action("Page Calc. Standard Cost")
                    {
                        ApplicationArea = All;
                        Caption = 'Calc. Stan&dard Cost';
                        Image = CalculateCost;

                        trigger OnAction()
                        begin
                            Clear(CalculateStdCost);
                            CalculateStdCost.CalcItem(Rec."No.", false);
                        end;
                    }
                }
                action("Page Prepack")
                {
                    ApplicationArea = All;
                    Caption = 'Prepack';
                    Image = BOMRegisters;

                    trigger OnAction()
                    var
                        lRetailBOMComp: Codeunit "LSC Retail BOM Components";
                    begin
                        lRetailBOMComp.RetailBOMViewEdit(Rec."No.", true);
                    end;
                }
            }
            group("&Warehouse")
            {
                Caption = '&Warehouse';
                action("Stockkeepin&g Units")
                {
                    ApplicationArea = All;
                    Caption = 'Stockkeepin&g Units';
                    Image = SKU;
                    RunObject = Page "Stockkeeping Unit List";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.");
                }
            }
            group("&Item")
            {
                Caption = '&Item';
                action("List by Ba&rcodes")
                {
                    ApplicationArea = All;
                    Caption = 'List by Ba&rcodes';
                    Image = Item;

                    trigger OnAction()
                    var
                        Barcodes_l: Record "LSC Barcodes";
                    begin
                        Barcodes_l.Reset;
                        // >> Upgrade
                        //if PAGE.RunModal(PAGE::"LSC Rtl Item List by Barcodes", Barcodes_l) = ACTION::LookupOK then begin
                        if PAGE.RunModal(PAGE::"LSC Rtl Item List by Barcodes", Barcodes_l) = ACTION::LookupOK then begin
                            // << Upgrade
                            Rec.SetRange("No.", Barcodes_l."Item No.");
                            CurrPage.Update;
                        end;
                    end;
                }
            }
            group("LS Recommend")
            {
                Caption = 'LS Recommend';
                action(AddItemToRecommendationCatalog)
                {
                    ApplicationArea = All;
                    Caption = 'Add Item to Catalog';
                    Image = Add;

                    trigger OnAction()
                    var
                    // >> Upgrade
                    //LSRecommendsFunctions: Codeunit "LS Recommends Functions";
                    //LSRecommendsFunctions: Codeunit 10016250; //This codeunit or relevant codeunit is not available in AL
                    // << Upgrade
                    begin
                        //LSRecommendsFunctions.Initialize(false);
                        //LSRecommendsFunctions.AddItemToCatalog(Rec);
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Insert New Item Defaults")
                {
                    ApplicationArea = All;
                    Caption = 'Insert New Item Defaults';
                    Image = ApplyTemplate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "LSC Item Creation";
                }
                action("&Find Barcode")
                {
                    ApplicationArea = All;
                    Caption = '&Find Barcode';
                    Image = BarCode;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+F';

                    trigger OnAction()
                    var
                        Barcodes_l: Record "LSC Barcodes";
                        Item_l: Record Item;
                        //>>upgrade
                        //BarcodeMgmt: Codeunit "Barcode Management LS";
                        BarcodeMgmt: Codeunit "LSC Fc Barcode Management";
                        //<<upgrade
                        Window: Page "LSC Find Barcode";
                        BCode: Code[22];
                        Amount: Decimal;
                        Qty: Decimal;
                    begin
                        BCode := '';
                        if Window.RunModal = ACTION::OK then
                            BCode := Window.GetBarcode;
                        if BarcodeMgmt.FindBarcodeDetails(BCode, Item_l, Barcodes_l, Amount, Qty) then
                            if Item_l.Get(Barcodes_l."Item No.") then
                                Rec := Item_l
                            else
                                Message(Text003 + Barcodes_l."Item No.")
                        else
                            Message(Text004);
                    end;
                }
                action("&Create Stockkeeping Unit")
                {
                    ApplicationArea = All;
                    Caption = '&Create Stockkeeping Unit';
                    Image = CreateSKU;

                    trigger OnAction()
                    var
                        Item_l: Record Item;
                    begin
                        Item_l.SetRange("No.", Rec."No.");
                        REPORT.RunModal(REPORT::"Create Stockkeeping Unit", true, false, Item_l);
                    end;
                }
                action("C&alculate Counting Period")
                {
                    ApplicationArea = All;
                    Caption = 'C&alculate Counting Period';
                    Image = CalculateCalendar;

                    trigger OnAction()
                    var
                        PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
                    begin
                        PhysInvtCountMgt.UpdateItemPhysInvtCount(Rec);
                    end;
                }
                action(ChangeItemStatusBatch)
                {
                    ApplicationArea = All;
                    Caption = 'Change Item Status Batch';
                    Image = ChangeBatch;

                    trigger OnAction()
                    var
                        ActiveItem: Record Item;
                    begin
                        ActiveItem.SetRange("No.", Rec."No.");
                        REPORT.RunModal(10001415, true, false, ActiveItem);
                    end;
                }
                action(ClearAttributes)
                {
                    ApplicationArea = All;
                    Caption = 'Clear Attributes Filters';
                    Image = RemoveFilterLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Remove the filter for specific item attributes.';

                    trigger OnAction()
                    begin
                        Rec.ClearMarks;
                        Rec.MarkedOnly(false);
                        AttributeFilterBuffer.Reset;
                        AttributeFilterBuffer.DeleteAll;
                        Rec.FilterGroup(0);
                        Rec.SetRange("No.");
                    end;
                }
            }
            group("G&roups")
            {
                Caption = 'G&roups';
                action(Divisions)
                {
                    ApplicationArea = All;
                    Caption = 'Divisions';
                    Image = ItemGroup;
                    //PromotedCategory = Process;
                    RunObject = Page "LSC Divisions";
                }
                action("Item Category")
                {
                    ApplicationArea = All;
                    Caption = 'Item Category';
                    Image = ItemGroup;
                    //PromotedCategory = Process;

                    trigger OnAction()
                    var
                        RetailItemCategory: Page "LSC Retail Item Category";
                        ItemCategoryRec: Record "Item Category";
                    begin
                        if ItemCategoryRec.Get(Rec."Item Category Code") then
                            RetailItemCategory.SetRecord(ItemCategoryRec);
                        RetailItemCategory.Run;
                    end;
                }
                action("Product Group")
                {
                    ApplicationArea = All;
                    Caption = 'Product Group';
                    Image = ItemGroup;
                    //PromotedCategory = Process;

                    trigger OnAction()
                    var
                        ProductGroup: Record "LSC Retail Product Group";
                        RetailProductGroup: Page "LSC Retail Product Group";
                    begin
                        //LS-12322 //IF ProductGroup.GET("Item Category Code","Product Group Code") THEN
                        if ProductGroup.Get(Rec."Item Category Code", Rec."LSC Retail Product Code") then//LS-12322
                            RetailProductGroup.SetRecord(ProductGroup);
                        RetailProductGroup.Run;
                    end;
                }
            }
            action("Sales Prices")
            {
                ApplicationArea = All;
                Caption = 'Sales Prices';
                Image = SalesPrices;
                RunObject = Page "Sales Prices";
                RunPageLink = "Item No." = FIELD("No.");
                RunPageView = SORTING("Item No.");
            }
            action("Requisition Worksheet")
            {
                ApplicationArea = All;
                Caption = 'Requisition Worksheet';
                Image = Worksheet;
                //PromotedCategory = Process;
                RunObject = Page "Req. Worksheet";
            }
            action("Item Journal")
            {
                ApplicationArea = All;
                Caption = 'Item Journal';
                Image = Journals;
                Promoted = true;
                PromotedCategory = Category5;
                RunObject = Page "Item Journal";
            }
            action("Item Reclassification Journal")
            {
                ApplicationArea = All;
                Caption = 'Item Reclassification Journal';
                Image = Journals;
                //PromotedCategory = Process;
                RunObject = Page "Item Reclass. Journal";
            }
            action("Item Tracing")
            {
                ApplicationArea = All;
                Caption = 'Item Tracing';
                Image = ItemTracing;
                //PromotedCategory = Process;
                RunObject = Page "Item Tracing";
            }
            action("Adjust Item Cost/Price")
            {
                ApplicationArea = All;
                Caption = 'Adjust Item Cost/Price';
                Image = AdjustItemCost;
                //PromotedCategory = Process;
                RunObject = Report "Adjust Item Costs/Prices";
            }
            action("Adjust Cost - Item Entries")
            {
                ApplicationArea = All;
                Caption = 'Adjust Cost - Item Entries';
                Image = AdjustEntries;
                //PromotedCategory = Process;
                RunObject = Report "Adjust Cost - Item Entries";
            }
            group(Hierarchies)
            {
                Caption = 'Hierarchies';
                action(PageItemLinks)
                {
                    ApplicationArea = All;
                    Caption = 'Item Links';
                    Image = Links;
                    RunObject = Page "LSC Item Links";
                    RunPageLink = "Item No." = FIELD("No.");
                }
            }
        }
        area(reporting)
        {
            group("&Inventory")
            {
                Caption = '&Inventory';
                action("Inventory - List")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - List';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "Inventory - List";
                }
                action("Item Register - Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Item Register - Quantity';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "Item Register - Quantity";
                }
                action("Inventory - Transaction Detail")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - Transaction Detail';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "Inventory - Transaction Detail";
                }
                action("Inventory Availability")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Availability';
                    Image = ItemAvailability;
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "Inventory Availability";
                }
                action(Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report Status;
                }
                action("Inventory - Availability Plan")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - Availability Plan';
                    Image = ItemAvailability;
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory - Availability Plan";
                }
                action("Inventory Cost and Price List")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Cost and Price List';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory Cost and Price List";
                }
                action("Phys. Inventory List")
                {
                    ApplicationArea = All;
                    Caption = 'Phys. Inventory List';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Phys. Inventory List";
                }
                action("Item Expiration - Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Item Expiration - Quantity';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Item Expiration - Quantity";
                }
            }
            group("&Sales")
            {
                Caption = '&Sales';
                action("Inventory - Customer Sales")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - Customer Sales';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory - Customer Sales";
                }
                action("Inventory - Sales Statistics")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - Sales Statistics';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory - Sales Statistics";
                }
                action("Inventory - Top 10 List")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - Top 10 List';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "Inventory - Top 10 List";
                }
                action("Inventory Order Details")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Order Details';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory Order Details";
                }
                action("Price List")
                {
                    ApplicationArea = All;
                    Caption = 'Price List';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "Price List";
                }
                action("Inventory - Reorders")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - Reorders';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory - Reorders";
                }
                action("Inventory - Sales Back Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - Sales Back Orders';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory - Sales Back Orders";
                }
                action("Nonstock Item Sales")
                {
                    ApplicationArea = All;
                    Caption = 'Nonstock Item Sales';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Catalog Item Sales";
                }
                action("Item Substitutions")
                {
                    ApplicationArea = All;
                    Caption = 'Item Substitutions';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Item Substitutions";
                }
            }
            group(Action1100409142)
            {
                Caption = '&Purchases';
                action("Inventory Purchase Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Purchase Orders';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory Purchase Orders";
                }
                action("Inventory - Vendor Purchases")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory - Vendor Purchases';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Inventory - Vendor Purchases";
                }
                action("Item Age Composition - Qty.")
                {
                    ApplicationArea = All;
                    Caption = 'Item Age Composition - Qty.';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Item Age Composition - Qty.";
                }
                action("Item/Vendor Catalog")
                {
                    ApplicationArea = All;
                    Caption = 'Item/Vendor Catalog';
                    Image = "Report";
                    //PromotedCategory = "Report";
                    RunObject = Report "Item/Vendor Catalog";
                }
            }
            group("&Finance/Costing")
            {
                Caption = '&Finance/Costing';
                group("&Financial Mgmt.")
                {
                    Caption = '&Financial Mgmt.';
                    Image = "Report";
                    action("Inventory Valuation")
                    {
                        ApplicationArea = All;
                        Caption = 'Inventory Valuation';
                        Image = "Report";
                        //PromotedCategory = "Report";
                        RunObject = Report "Inventory Valuation";
                    }
                    action("Item Age Composition - Value")
                    {
                        ApplicationArea = All;
                        Caption = 'Item Age Composition - Value';
                        Image = "Report";
                        Promoted = true;
                        PromotedCategory = "Report";
                        RunObject = Report "Item Age Composition - Value";
                    }
                    action("Item Register - Value")
                    {
                        ApplicationArea = All;
                        Caption = 'Item Register - Value';
                        Image = "Report";
                        //PromotedCategory = "Report";
                        RunObject = Report "Item Register - Value";
                    }
                    action("Item Charges - Specification")
                    {
                        ApplicationArea = All;
                        Caption = 'Item Charges - Specification';
                        Image = "Report";
                        //PromotedCategory = "Report";
                        RunObject = Report "Item Charges - Specification";
                    }
                    action("Detailed Calculation")
                    {
                        ApplicationArea = All;
                        Caption = 'Detailed Calculation';
                        Image = "Report";
                        //PromotedCategory = "Report";
                        RunObject = Report "Detailed Calculation";
                    }
                }
                group("&Costing")
                {
                    Caption = '&Costing';
                    Image = "Report";
                    action("Invt. Valuation - Cost Spec.")
                    {
                        ApplicationArea = All;
                        Caption = 'Invt. Valuation - Cost Spec.';
                        Image = "Report";
                        //PromotedCategory = "Report";
                        RunObject = Report "Invt. Valuation - Cost Spec.";
                    }
                    action("Cost Shares Breakdown")
                    {
                        ApplicationArea = All;
                        Caption = 'Cost Shares Breakdown';
                        Image = CostAccountingDimensions;
                        //PromotedCategory = "Report";
                        RunObject = Report "Cost Shares Breakdown";
                    }
                    action("Inventory - Cost Variance")
                    {
                        ApplicationArea = All;
                        Caption = 'Inventory - Cost Variance';
                        Image = ItemCosts;
                        //PromotedCategory = "Report";
                        RunObject = Report "Inventory - Cost Variance";
                    }
                    action("Single-level Cost Shares")
                    {
                        ApplicationArea = All;
                        Caption = 'Single-level Cost Shares';
                        Image = "Report";
                        //PromotedCategory = "Report";
                        RunObject = Report "Single-level Cost Shares";
                    }
                    action("Rolled-up Cost Shares")
                    {
                        ApplicationArea = All;
                        Caption = 'Rolled-up Cost Shares';
                        Image = "Report";
                        //PromotedCategory = "Report";
                        RunObject = Report "Rolled-up Cost Shares";
                    }
                }
            }
            group("&Other")
            {
                Caption = '&Other';
                action("Profit Goals")
                {
                    ApplicationArea = All;
                    Caption = 'Profit Goals';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "LSC Profit Goals";
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        GXLLimitToStoreUser();
    end;

    trigger OnAfterGetRecord()
    begin
        Barcodes.SetCurrentKey("Item No.");
        Barcodes.SetRange("Item No.", Rec."No.");
        Barcodes.SetRange("Show for Item", true);
        if Barcodes.FindFirst then
            BarcodeNo := Barcodes."Barcode No."
        else begin
            Barcodes.SetRange("Show for Item");
            if Barcodes.FindFirst then
                BarcodeNo := Barcodes."Barcode No."
            else
                BarcodeNo := '';
        end;
        Rec.GXLGetFamilyStructureDescText(GXL_strText);
        GXLGetRetailPrice();
        Rec.CalcFields(Inventory);
        SOH := Rec.Inventory;
    end;

    trigger OnOpenPage()
    begin
        if not RetailUser.Get(UserId) then
            Clear(RetailUser);
        GXLLimitToStoreUser();
    end;

    trigger OnInit()
    var
        FileManagement: Codeunit "File Management";
    begin
        // >> Upgrade
        //VisibleInWebClient := FileManagement.IsWebClient;
        //VisibleInWinClient := FileManagement.IsWindowsClient;
        VisibleInWebClient := true;
        // << Upgrade
    end;

    var
        Barcodes: Record "LSC Barcodes";
        RetailUser: Record "LSC Retail User";
        AttributeFilterBuffer: Record "LSC Attribute Filter Buffer" temporary;
        CalculateStdCost: Codeunit "Calculate Standard Cost";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        BarcodeNo: Code[22];
        Text003: Label 'Barcode found\item not found =';
        Text004: Label 'Barcode not found';
        Text008: Label 'The item does not have variants.';
        VisibleInWebClient: Boolean;
        VisibleInWinClient: Boolean;
        Text022: Label '%1 is not linked to %2';
        GXL_strText: array[5] of Text;
        UnitPrice: Decimal;
        SOH: Decimal;
        DictItem: Dictionary of [Code[20], Decimal];


    procedure ReturnSelectionFilter(var Item: Record Item)
    begin
        CurrPage.SetSelectionFilter(Item);
    end;

    local procedure GXLGetRetailPrice()
    var
    begin
        if RetailUser."Store No." <> '' then begin
            if not DictItem.Get(Rec."No.", UnitPrice) then begin
                UnitPrice := PDAItemIntegration.GetRetailPrice(Rec, RetailUser."Store No.");
                DictItem.Add(Rec."No.", UnitPrice);
            end;
        end else
            UnitPrice := Rec."Unit Price";
    end;

    local procedure GXLLimitToStoreUser()
    begin
        if RetailUser."Location Code" <> '' then
            Rec.SetFilter("Location Filter", RetailUser."Location Code");
    end;
}

