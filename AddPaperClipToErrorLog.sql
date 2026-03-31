SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.AddPaperClipToErrorLog (@ErrorText VARCHAR(100))
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorLine VARCHAR(250);

	DECLARE @NonTrademarkedPaperClip VARCHAR(MAX) = 
'                                                                                 
                                \\\||||||||||||||||||||\\                            
                           .::\\\\:..       ..\\|||||\:                        
                           .\::.                    :||||||\:                      
                ::\\\||||||||||\\                    :::|||\:                     
         ..\\|||||||||||||||||||||||||||||\                  \\\\.                     
      .:\\\:         \\:.                         ||||||||||||||\\:.              
                                                   ::\|||||\\\||||||||||\:          
             .\\\\\\:.    \:..                ...             .::||||\:       
    ...    \||||||||||||||||||||||\ ..\\                             .::    :\\:     
    :\..  :|||||||||||||||||||||\: .\\\      ...    :\||||||||||||||||\    \:::          
    ..:\\:  ..:::::.    ..\\\..     ..:\    :||||||||||||||||||||||||   .\\..        
           .::..  \\\\\..             ::\\    \\|||||||||||\..  \\\          
                  \|||||\\                  ..:::::         ..::\\\.            
                  \|||||\:                       \||||||||  ...                     
                  \|||||\:  |||||||..              \:||||||\        \||||\           
                  \|||||\: \||||||                \\|||\:      \|||||||\            
                  \|||||\:  ||||||\               \:|||\\    \\|||||:              
                  \\||\\ \||||\               :\||||\:    \\||\\              
                  \\||\\ \\||\               \:|||\\    \\\\.              
                  \:|||\\ :\\\..             .::|||\\    \\\::               
                  .::|||\:  \\|\:.               :|||\\   :|||\\\              
                    :|||\:    \|\\               \\\:    \\\\:              
                    :|||\\.  :\||||::.           ..\\\    :\\\\               
                    :\||||::.    \|||||\\\:::\\\\\      :\||||\\              
                       |||\\..    ..\\\\\\\\:.        :\||||\\              
                       \||||\:                              \:||||\:              
                         \|\\                             .\\|\\              
                         \:|||\:                            \\|\:.              
                           :\||||\:                       :\\\\                
                              \\|||||\\:.       ..::\\\\\:.                   
                                  :\||||||||\\\\\\\\\:                        
';

	DECLARE cErrorLines CURSOR LOCAL FAST_FORWARD FOR
	SELECT '. ' + value + SPACE(10) + 
	+ case ordinal
	when 10 then ' ' + REPLICATE('_', 1.0 * LEN(@ErrorText))
	when 11 then '| ' + @ErrorText
	when 12 then '| Would you like help?'
	when 13 then '| ' + REPLICATE('_', 1.0 * LEN(@ErrorText))
	else '' end ErrorLine
	FROM STRING_SPLIT(@NonTrademarkedPaperClip, CHAR(10), 1)
	ORDER BY ordinal DESC;

	OPEN cErrorLines;
	FETCH NEXT FROM cErrorLines INTO @ErrorLine;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- try to prevent lines from appearing out of order
		WAITFOR DELAY '00:00:00:005';

		EXEC xp_logevent 80085, @ErrorLine;

		FETCH NEXT FROM cErrorLines INTO @ErrorLine;
	END;

	CLOSE cErrorLines;
	DEALLOCATE cErrorLines;

	RETURN;
END;
GO