//%attributes = {}
/* Purpose: unit test for entitySave
 ------------------
entitySave__TEST ()
 Created by: Kirk as Designer, Created: 12/21/23, 10:50:06

https://developer.4d.com/docs/API/EntityClass#save

To start keep in mind that in c/s:
.save() always runs ON THE SERVER
regardless of where you instantiated $entity. 
Triggers ONLY RUN ON THE SERVER

In general, an entity is a REFERENCE to the data (the record)
but it's not actually the record. This is a big difference between 
records and entities. Also, entities have state and in most cases
you have to explicitly change that state for it to be reflected in
the entity. 

References take up practically no memory. This is another huge
distiction between classic and ORDA. 4D manages the actual data
associated with a reference and it is very efficient. So multiple 
references do not correlate directly to increased memory foot print. 

You can have multiple references to the same record at the same time. 
This was totally unavailable in classic 4D. It's illustrated below 
and worth exploring. 

You can not pass an entity or entity selection between the server and a client. 
In classic it was really efficient to have the server get an array of data,
for example, and pass that to a client. Or for a client to pass an array of data
to the server and look up the records, update from the array and save them there. 

This is not the case with ORDA. It is more efficient to get an entity
or entity selection on the client, update and save them on the client. 
4D is super optimized for this sort of thing when using ORDA. 

These are reasons entitySave() doesn't execute on the server. 
*/

var $entity1; $entity2 : cs.Table_1Entity
var $result1; $result2 : Object
var $id1 : Text

TRUNCATE TABLE([Table_1])

// NOTE: several asserts fail. Be sure to read about why

//mark:  --- create an entity
$entity1:=ds.Table_1.new()
$entity1.Field_2:="test record"
$result1:=Entity_save($entity1)
ASSERT($result1.success)

$id1:=$entity1.ID

//mark:  --- what happens if we try to create another entity with the same PK?
$entity2:=ds.Table_1.new()
$entity2.ID:=$id1
$entity2.Field_2:="duplicate test record"
$result2:=Entity_save($entity2)
ASSERT(Not($result2.success))
TRACE  //  take a look at $result2 to see what this error looks like

//mark:  ---  now what happens if we get ANOTHER reference to the entity?
$entity2:=ds.Table_1.get($id1)
// At the moment the values of these two are identical
// what if we change one of them and save it?
$entity2.Field_2:="I have changed this record"
$result2:=Entity_save($entity2)
ASSERT($result2.success)

TRACE  // look at the value Field_2 in $entity1 and $entity2
// They are different because they are different REFERNCES to the same record.
// A reference has state and these two references have different states. 

//mark:  --- What happens if I change a different field on $entity1 and call .save()?
$entity1.Field_4:=Generate UUID
$result1:=$entity1.save()
ASSERT($result1.success; "This fails because the record was changed on line 40")
// .save() fails is there has been any change the entity since I got the reference
// entitySave() will automatically attempt to merge my changes with the record
// if I haven't overwritten anything already changed. In this case since I did not
// update Field_2 my change doesn't affect the previous change and the merge will work
$result1:=Entity_save($entity1)
ASSERT($result1.success)
TRACE  //  notice that result informs you it used automerge

//mark:  --- what if I change a field already changed?
$entity2.Field_3:=Generate UUID
$result2:=Entity_save($entity2)
ASSERT($result2.success; $result2.statusText)
// The automerge won't overwrite changes already made

//mark:  --- How to force changes
// If I have changes that simply must be written even if I know
// I'm going to overwrite other changes recently made the process is
// 1) get the current state of the record in a new entity (reference)
// 2) write the changes in my entity to this one
// 3) save the new reference
// entitySave() can attempt this or you can write your own method to do it. 
// with entitySave() it's all or nothing and there is no error or integrity checking.
// If you write your own you can examine each change and evaluate whether it's a good
// change or not. You can use the code in entitySave() as a template for your own code. 

// I'm going to 
$entity2.Field_3:=Generate UUID
$entity2.Field_2:="I have forced these changes!"
$result2:=Entity_save($entity2; True)  //  $2 enables force update
ASSERT($result2.success; $result2.statusText)  //  note that $result2 let's you know it used forceSave

//mark:  --- What happens if the entity is locked in another process?
LoadARecord($id1)

$entity1.Field_4:="This record is locked"
$result1:=$entity1.save()
ASSERT($result1.success; "This fails because the record is locked")
/*  look at $entity1 in the debugger. Notice Field_3 is not updated.
This is because your reference to $entity1 has not be updated
with those changes. If you call .reload() you will see the changes
but then loose your changes to Field_4.
Let's see if the record is available now...
*/
TRACE


Repeat 
	$result1:=Entity_save($entity1)
Until ($result1.success)

TRACE
// look at $entity1 in the debugger now.
// the save was completed using the automerge option and
// this worked because the changes in this process and the
// changes in the other process do not conflict.

