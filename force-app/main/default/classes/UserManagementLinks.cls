/*************************************************************************************
Class Name - UserManagementLinks
Version - 1.0
Created Date - 26 November 2020
Function - manage all UserManagementLinks
    
Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Welsa C      26/11/2020  C-003986 - NOB - User Management
* Welsa C      15/03/2021  C-004231 - reset pwd & un unlock user pour le profile PRE_FRONT Office.
**************************************************************************************/
global class UserManagementLinks {

    //Method that can is called from the Visual Force page action attribute
    webservice static string resetUserPassword(Id usrid) {
        try{
            System.resetPassword(usrid, true);
        }catch(Exception e){
            return (String) e.getMessage();
        }
        return '1';
    }
    webservice static string ActivateDeactivateUser(Id usrid) {
        try{
            
            List<User> usersToUpdate = new List<User>();
            for(User u : [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where Id=:usrid]){
                if(u.IsActive){
                    u.IsActive = false;
                    //u.IsPortalEnabled = false;
                }else{
                    u.IsActive = true;
                    //u.IsPortalEnabled = true;
                }
                usersToUpdate.add(u);
            }

            if (usersToUpdate.size()>0){
                update usersToUpdate;
            }

        }catch(Exception e){
            return (String) e.getMessage();
        }
        return '1';
    }
    webservice static string UnlockUser(Id usrid) {
        try{
            
            List<UserLogin> usersToUpdate = new List<UserLogin>();
            for(UserLogin u : [Select IsPasswordLocked from UserLogin where UserId=:usrid]){
                if(u.IsPasswordLocked){
                    u.IsPasswordLocked = false;
                }
                usersToUpdate.add(u);
            }

            if (usersToUpdate.size()>0){
                update usersToUpdate;
            }

        }catch(Exception e){
            return (String) e.getMessage();
        }
        return '1';
    }
}