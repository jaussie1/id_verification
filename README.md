# ID Verification

## Overview

The ID verification feature is used to confirm a user's identity before granting individual seller access on Osomba. It applies to supported identity documents such as:

- DRC voter IDs
- DRC Driver's licenses
- DRC Passports

This process helps ensure that only users with valid identity documents can become individual sellers on the platform.

## Purpose

The purpose of the ID verification workflow is to:

- validate the legitimacy of submitted identity documents
- prevent unauthorized users from obtaining seller privileges
- promote verified users from buyer status to seller status
- strengthen trust and accountability in the marketplace

## Workflow Summary

The ID verification workflow begins when a user chooses to become an individual seller. This can happen in two ways:

1. During onboarding, when the user selects the individual seller option
2. From the profile screen, when the user chooses to start selling later

In both cases, the user is directed to the ID verification screen.

On the ID verification screen, the user uploads or captures an image of a supported identity document. When the user taps the verify button, the app sends the image to
the backend verification API.

The backend first validates the uploaded file and then passes the image to the machine learning verification service. The ML service loads the trained EfficientNet-B0
model, preprocesses the image, performs inference, and determines whether the submitted document appears legitimate.

The result is returned to the backend API endpoint, which then updates the user's record through the CRUD layer. If the document is accepted, the system marks the user
as verified, promotes the user from buyer to seller, and records the seller activation timestamp. If the document is rejected, the user remains unverified and is not
granted seller access.

Finally, the backend sends the updated result back to the mobile app. The app updates the user state and routes verified users into the seller experience.

## Core Components

The ID verification feature is built from four main parts:

- **ID Verification Screen**
  - provides the user interface for uploading or capturing an ID image

- **API Endpoint**
- **ML Service**
  - evaluates the ID image using a trained EfficientNet-B0 model

- **CRUD Function**
  - updates the user's verification status and seller role in the database

## Success Outcome

If verification succeeds:

- the user is marked as verified
- the user is promoted from buyer to seller
- the seller activation timestamp is stored
- the app updates the user's state
- the user is routed into the seller flow

## Failure Outcome

If verification fails:

- the user is not granted seller access
- the verification screen remains active
- an error message is shown to the user

If the verification service is unavailable:

- the backend returns an error response
- the app displays the error
- the user remains on the verification screen

## Model Used

The machine learning component uses a trained **EfficientNet-B0** model for ID legitimacy classification.

Its role is to analyze uploaded identity document images and determine whether they are likely valid or invalid based on the learned patterns from training data.

## Summary

In summary, the ID verification feature combines a mobile upload interface, a backend verification endpoint, a machine learning classification service, and database
update logic to ensure that only users with valid identity documents such as DRC voter IDs, driver's licenses, and passports can obtain individual seller access on
Osomba.
