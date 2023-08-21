from fastapi import APIRouter, Depends
from global_var import supabase, allowed_coupon_to_roles, coupon_types
import routers.auth.auth as auth
from db.supa import Supa
from postgrest import exceptions

router = APIRouter()


@router.post("/gen/qr/{coupon_type}")
async def generate_qr(
    coupon_type: str, user_state: auth.UserAuthState = Depends(auth.check_auth_state)
):
    db_client = Supa(supabase)
    try:
        print(user_state)
        response = db_client.get_user_role(user_state.supabase_id)
        role_type = response.data[0]["role_name"]
        allowed_coupon_types = allowed_coupon_to_roles[role_type]
        if coupon_type in allowed_coupon_types:
            try:
                response = db_client.get_in_wallet_balance(
                    user_id=user_state.supabase_id
                )
                if float(response.data[0]["in_wallet"]) == 0:
                    response = db_client.get_account_balance(
                        user_id=user_state.supabase_id
                    )
                    if float(response.data[0]["balance"]) >= float(
                        coupon_types[coupon_type]
                    ):
                        try:
                            procedure_response = db_client.gen_qr_procedure(
                                user_id=user_state.supabase_id,
                                new_balance=float(response.data[0]["balance"])
                                - float(coupon_types[coupon_type]),
                                value_of_coupon=coupon_types[coupon_type],
                                coupon_type=coupon_type,
                            )
                            return {
                                "status": "200",
                                "detail": {
                                    "qr_data": f"{procedure_response}",
                                    "user_state": user_state,
                                },
                            }
                        except exceptions.APIError as err:
                            return {"status": "422", "detail": f"{err}"}
                    else:
                        return {"status": "422", "detail": "Not enough balance left"}
                else:
                    return {"status": "401", "detail": "An active food coupon is already generated"}
            except exceptions.APIError as err:
                return {"status": "422", "detail": f"{err}"}
        else:
            return {"status": "401", "detail": "Unauthorized to generate this qr!"}
    except exceptions.APIError as err:
        return {"status": "422", "detail": f"{err}"}