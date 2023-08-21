from fastapi import APIRouter, Depends
from global_var import (
    supabase,
    UserMongoBlueprint,
    parser,
    roles_list,
    block_list,
    bank_balance_per_role,
)
from postgrest import exceptions
from db.supa import Supa
import routers.auth.auth as auth

router = APIRouter()


@router.post("/gen/admin/{user_id}")
async def gen_user_in_mongo(
    user_id: str,
    user_to_add: UserMongoBlueprint,
    user_state: auth.UserAuthState = Depends(auth.check_auth_state),
):
    if parser["SUPABASE"]["sup_admin"] == user_id:
        if user_to_add.role in roles_list:
            try:
                db_client = Supa(supabase=supabase)
                response = db_client.generate_user(user_to_add)
                print(response)
                if user_to_add.role not in block_list:
                    response = db_client.generate_account(
                        user_to_add, bank_balance_per_role
                    )
                return {"status": "200", "detail": {"response": response, "user_state": user_state}}
            except exceptions.APIError as err:
                return {"status": "422", "detail": f"{err}"}
        else:
            return {
                "status": "422",
                "detail": "Please only input roles that are defined",
            }
    else:
        return {"status": "401", "detail": "Not Authorized"}
