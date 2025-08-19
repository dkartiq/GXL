dotnet
{
    // >> Upgrde
    //This dotnet variable was used to pop an input box which was handled by BC Native feature
    // assembly("Microsoft.VisualBasic")
    // {
    //     Version = '10.0.0.0';
    //     Culture = 'neutral';
    //     PublicKeyToken = 'b03f5f7f11d50a3a';

    //     type("Microsoft.VisualBasic.Interaction"; "Interaction")
    //     {
    //     }
    // }
    // << Upgrade
    assembly(mscorlib)
    {
        type(System.IO.File; File1) { }
        // >> Upgrade
        type(System.Convert; Convert1)
        { }
        type(System.Array; Array1)
        { }
        type("System.IO.MemoryStream"; MemoryStream1)
        { }
        type("System.Text.Encoding"; Encoding1)
        { }
        type("System.IO.Path"; Path1)
        { }
        type("System.String"; String1)
        { }
        // << Upgrade
    }

}
