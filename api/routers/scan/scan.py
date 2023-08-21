from fastapi import APIRouter, Depends
import routers.auth.auth as auth
from db.supa import Supa
from global_var import supabase, parser
from postgrest import exceptions
import jwt

router = APIRouter()


@router.post("/scan/qr/{jwt}")
async def scan_qr(
    jwt_encoded: str, user_state: auth.UserAuthState = Depends(auth.check_auth_state)
):
    db_client = Supa(supabase)
    try:
        response = db_client.get_user_role(user_id=user_state.supabase_id)
        if (
            response.data[0]["role_name"] == "VEND"
            or response.data[0]["role_name"] == "CC"
        ):
            jwt_decoded = jwt.decode(
                jwt_encoded, parser["QR"]["secret_key"], algorithms=["HS256"]
            )
            db_client.scan_qr_procedure(
                user_id=jwt_decoded["user_id"],
                jwt_encoded_str=jwt_encoded,
                vend_id=user_state.supabase_id,
                coupon_type=jwt_decoded["coupon_type"],
            )
            return {"status": "200", "detail": {"user_state": user_state}}
        else:
            return {"status": "401", "detail": "not authorized"}

    except exceptions.APIError as err:
        return {"status": "401", "detail": "rls banned"}
