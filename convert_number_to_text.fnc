CREATE OR REPLACE FUNCTION UKBS."convert_number_to_text" (
    ad_number IN NUMBER
)
  RETURN VARCHAR2
AS
ldec_deger NUMBER;
l          NUMBER;
i          NUMBER;
n          NUMBER;
j          number;

ls_alan VARCHAR2(1000) ;
ls_str  VARCHAR2(1000);
ls_yaz  VARCHAR2(1000);
ls_Sayi  dbms_utility.uncl_array;
ls_lira_kisa_adi VARCHAR2(1000);
ls_kurus_kisa_adi  VARCHAR2(1000);
ls_kurus  VARCHAR2(1000);
li_kurus NUMBER;

BEGIN

ls_Sayi(1) := 'Bir';
ls_Sayi(2) := 'Ýki';
ls_Sayi(3) := 'Üç';
ls_Sayi(4) := 'Dört';
ls_Sayi(5) := 'Beþ';
ls_Sayi(6) := 'Altý';
ls_Sayi(7) := 'Yedi';
ls_Sayi(8) := 'Sekiz';
ls_Sayi(9) := 'Dokuz';
ls_Sayi(10) := 'On';

ls_Sayi(11) := 'Yirmi';
ls_Sayi(12) := 'Otuz';
ls_Sayi(13) := 'Kýrk';
ls_Sayi(14) := 'Elli';
ls_Sayi(15) := 'Altmýþ';
ls_Sayi(16) := 'Yetmiþ';
ls_Sayi(17) := 'Seksen';
ls_Sayi(18) := 'Doksan';
ls_Sayi(19) := '19';

ls_Sayi(21) := 'Yüz';
ls_Sayi(22) := 'Bin';
ls_Sayi(23) := 'Onbin';
ls_Sayi(24) := 'Yüzbin';
ls_Sayi(25) := 'Milyon';
ls_Sayi(26) := 'Milyar';
ls_Sayi(27) := 'Trilyon';

  SELECT MAX(KISA_ADI),MAX(KURUS_KISA_ADI)
  INTO ls_lira_kisa_adi,ls_kurus_kisa_adi
  FROM SIS_PARX_XXXXXX,HIB_DXXXX_X
 WHERE SIS_PARX_XXXXXX.NO = HIB_DXXXX_X.SIS_PARX_XXXXXX_NO
   AND HIB_DXXXX_X.AKTIF = 'E';



ls_alan := to_char(ad_number) ;



IF Instr(ls_alan,',',1,1) > 0 THEN

	ls_kurus :=Substr(ls_alan,Instr(ls_alan,',',1,1) + 1,99);

	IF Substr(ls_kurus,1,1) = '0' THEN
		li_kurus := to_number(ls_kurus);
	ELSIF length(To_char(to_number(ls_kurus))) = 1 THEN
		li_kurus := to_number(ls_kurus) * 10 ;
	ELSE
		li_kurus := to_number(ls_kurus) ;
	END IF;
	ls_alan := Substr(ls_alan,1,Instr(ls_alan,',',1,1) - 1) ;

  	CAse
		when li_kurus between  1 and  9 then
			ls_kurus := ls_sayi(to_number(ls_kurus)) ||''|| ls_kurus_kisa_adi ;
		when li_kurus between  10 and  99 then
			IF to_number(Substr(ls_kurus,2,1)) <> 0 THEN
				ls_kurus := ls_sayi(to_number(Substr(ls_kurus,1,1)) + 9) ||''|| ls_Sayi(to_number(Substr(ls_kurus,2,1))) ||''|| ls_kurus_kisa_adi ;
			ELSE
				ls_kurus := ls_sayi(to_number(Substr(ls_kurus,1,1)) + 9) ||''|| ls_kurus_kisa_adi ;
			END IF ;
	End case ;

END IF	;

l := Length (ls_alan);

ls_str := '             ';

ls_str := Substr(ls_str,1, 14 - l - 1) ||''|| Substr(ls_alan,1,l);
ls_yaz :='/*';
i:=14 - l ;
while i <= to_number('13')  loop
   ldec_deger :=  to_number(Substr(ls_str,i,1)) ;


	 IF ldec_deger > 0 THEN 
   
      IF i=1 OR i='4' OR i='7' OR i='10' OR i='13' THEN    -- Birler
         n := to_number(nvl(trim(Substr(ls_str,8,3)),0));
         IF i=10 AND n=1 THEN        -- birbin yazmamak icin
           ls_yaz := Trim(ls_yaz);
         ELSE
           ls_yaz := Trim(ls_yaz) ||''|| to_char(ls_sayi(ldec_deger));
         END IF; 
      END IF;
     
		IF i=2 OR i=5 OR i=8 OR i=11 THEN             --....Yuzler
			IF ldec_deger < 2 THEN
				ls_yaz :=Trim(ls_yaz) ||''|| 'Yüz';
			ELSE
				ls_yaz :=Trim(ls_yaz) ||''|| to_char(ls_sayi(ldec_deger)) ||''|| 'yüz';
			END IF;
		END IF;


		IF i=3 OR i=6 OR i=9 OR i=12 THEN             --....Onlar
			ls_yaz := Trim(ls_yaz) ||''|| to_char(ls_sayi(ldec_deger + 9)) ;
		END IF;
  END IF;


    IF i=10 THEN
      ldec_deger := to_number(nvl(trim(Substr(ls_str,8,3)),0)) ;
      IF ldec_deger > 0 THEN
         ls_yaz := Trim(ls_yaz) ||''|| 'bin';
      END IF ;
    END IF;

    IF i=7 THEN
      ldec_deger := to_number(nvl(trim(Substr(ls_str,5,3)),0))  ;
      IF ldec_deger > 0 THEN
         ls_yaz :=Trim(ls_yaz) ||''|| 'milyon' ;
      END IF;
    END IF;

    IF i=4 THEN
      ldec_deger := to_number(nvl(trim(Substr(ls_str,2,3)),0)) ;
      IF ldec_deger>0 THEN
         ls_yaz :=Trim(ls_yaz) ||''|| 'milyar';
      END IF;
    END IF;
    IF i=1 THEN
       ls_yaz :=Trim(ls_yaz)  ||''|| 'trilyon';
    END IF;

    i:= i +1;
end loop ;


IF ad_number=0 THEN       -- Sifir
  ls_yaz :=Trim(ls_yaz) ||''|| 'sifir';
End If;

ls_yaz := Trim(ls_yaz) ||''|| ls_lira_kisa_adi ||''|| ls_kurus ||''|| '*/';


Return ls_yaz;

END convert_number_to_text;
/