pageextension 50046 "GXL Fixed Asset List" extends "Fixed Asset List"
{
    layout
    {
    }

    actions
    {
        addlast(Reporting)
        {
            //ERP-255 +
            action("GXL Petbarn Detailed FA")
            {
                Caption = 'Petbarn Detailed Fixed Asset';
                Image = Report;
                RunObject = report "GXL Petbarn Detailed FA";
            }
            //ERP-255 -
        }
    }

}