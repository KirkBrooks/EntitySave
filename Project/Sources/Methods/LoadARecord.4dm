//%attributes = {}
/* Purpose: lock and load the record for 30 seconds
 ------------------
LoadARecord ()
 Created by: Kirk as Designer, Created: 06/22/24, 11:58:49
*/

#DECLARE($id : Text)

If (Current process name=Current method name)
	//  just for fun use classic for this part
	QUERY([Table_1]; [Table_1]ID=$ID)  // this loads the record
	
	[Table_1]Field_3:="This was done with Classic!"
	SAVE RECORD([Table_1])
	
	PAUSE PROCESS(60*30)
	
	KILL WORKER  // unloads the record
	
Else 
	CALL WORKER(Current method name; Current method name; $ID)
End if 
