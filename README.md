# Optimistic Saving

This database presents a method for saving entities in 4D. It handles all the cases of a save function. 

A test method illustrates and discusses most of the common issues involved in optimistic saving. This also illustrates the nature of references and how you can have different references to the same record in different states at the same time. 

The EntitySave method includes an option for force-saving changes. This is a fairly brutal approach used here to illustrate options available to you for resolving locked record conflicts during a save. 

Optimistic locking allows us to manipulate an entity without regard to it’s locked state as much as we like but then it’s up to us to deal with the various issues arising from the save not working.

Pessimistic locking puts the burden of determining if you _can_ save any changes at the front with little worry about the save failing.

In both cases the situations like duplicate PK, the disk failing, the record no longer exists throw errors.

Optimistic locking has a lot of advantages especially in busy systems where records are being accessed and updated frequently by different processes and particularly when the nature of those changes doesn’t overlap. The flip side is you have to actually pay attention to the result of attempting the save.
