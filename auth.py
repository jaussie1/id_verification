@router.post("/verify-id", response_model=UserResponse)
async def verify_user_id(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Verifies the user's ID using an AI model and updates verification status.
    """
    # Read image bytes
    contents = await file.read()
    
    # Run AI verification
    is_legitimate = verify_id_image(contents)
    
    # Update user status
    user = user_crud.verify_user(db, current_user, is_legitimate)
    
    if not is_legitimate:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ID Verification failed. The ID is not legitimate."
        )
        
    return user
