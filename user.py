def verify_user(db: Session, user: User, is_verified: bool):
    """
    Updates the user's verification status.
    If the user was a BUYER and verification passes, they are promoted to SELLER.
    """
    user.is_verified = is_verified
    
    # Promotion Logic: If ID is legitimate and they are currently a BUYER,
    # they are upgraded to SELLER.
    if is_verified and user.role == UserRole.BUYER:
        user.role = UserRole.SELLER
    
    if user not in db:
        user = db.merge(user)
    
    db.commit()
    db.refresh(user)
    return user
