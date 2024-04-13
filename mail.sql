USE msdb  
GO  
EXEC sp_send_dbmail @profile_name='Andres Muñoz Pampillon',  
@recipients='[andresmunozpampillon@gmail.com](mailto:andresmunozpampillon@gmail.com)',  
@subject='Mensaje de prueba',  
@body='Felicidades ya puedes enviar correos  
desde tu base de datos'  