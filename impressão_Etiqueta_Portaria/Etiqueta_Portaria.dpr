program Etiqueta_Portaria;

uses
  Vcl.Forms,
  uImpressao in 'uImpressao.pas' {frmEtiqueta};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmEtiqueta, frmEtiqueta);
  Application.Run;
end.
