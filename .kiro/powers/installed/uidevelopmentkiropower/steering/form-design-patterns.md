# Form Design Patterns

## Overview

Forms are critical touchpoints in user interfaces where users provide information, make decisions, and complete tasks. Well-designed forms reduce friction, prevent errors, and ensure accessibility for all users. This guide provides comprehensive patterns for creating forms with excellent user experience, focusing on clear labeling, inline validation, appropriate input types, and accessible error handling.

Load this steering file when working with forms, input validation, user data collection, or any interface requiring user input.

## Core Principles

### 1. Clarity First

Every form field should have a clear, descriptive label that tells users exactly what information is expected. Labels should be visible at all times, not just placeholders.

### 2. Progressive Disclosure

Only ask for information you truly need. Break complex forms into logical steps or sections to reduce cognitive load.

### 3. Immediate Feedback

Validate input as users type (with appropriate debouncing) and provide clear, actionable error messages immediately when issues are detected.

### 4. Accessibility by Default

All forms must be keyboard navigable, screen reader friendly, and provide clear error announcements through ARIA live regions.

### 5. Mobile-Friendly Inputs

Use appropriate input types to trigger the correct mobile keyboard and provide a better mobile experience.

## Form Structure Best Practices

### Label Association

**Always associate labels with inputs** using the `for` attribute or by wrapping the input:

```jsx
// Good: Explicit association
<label htmlFor="email">Email Address</label>
<input type="email" id="email" name="email" />

// Good: Implicit association
<label>
  Email Address
  <input type="email" name="email" />
</label>

// Bad: No association
<div>Email Address</div>
<input type="email" name="email" />
```

### Required Field Indicators

Mark required fields clearly and consistently:

```jsx
// Good: Visual and semantic indication
<label htmlFor="name">
  Full Name <span aria-label="required">*</span>
</label>
<input
  type="text"
  id="name"
  name="name"
  required
  aria-required="true"
/>

// Include a legend explaining the asterisk
<p className="form-legend">
  <span aria-hidden="true">*</span> indicates required field
</p>
```

### Field Grouping

Group related fields using `<fieldset>` and `<legend>`:

```jsx
<fieldset>
  <legend>Shipping Address</legend>

  <label htmlFor="street">Street Address</label>
  <input type="text" id="street" name="street" required />

  <label htmlFor="city">City</label>
  <input type="text" id="city" name="city" required />

  <label htmlFor="zip">ZIP Code</label>
  <input type="text" id="zip" name="zip" required />
</fieldset>
```

## Input Types and Mobile Optimization

### Use Appropriate Input Types

Choosing the correct input type improves mobile experience by triggering the appropriate keyboard:

```jsx
// Email - triggers email keyboard with @ symbol
<input type="email" name="email" autoComplete="email" />

// Telephone - triggers numeric keyboard with special characters
<input type="tel" name="phone" autoComplete="tel" />

// Number - triggers numeric keyboard
<input type="number" name="quantity" min="1" max="99" />

// URL - triggers URL keyboard with .com shortcuts
<input type="url" name="website" />

// Date - provides native date picker
<input type="date" name="birthdate" />

// Search - provides search-specific keyboard and clear button
<input type="search" name="query" />
```

### Input Attributes for Better UX

```jsx
// AutoComplete for faster form filling
<input
  type="email"
  name="email"
  autoComplete="email"
  placeholder="you@example.com"
/>

// Input mode for numeric inputs without spinner
<input
  type="text"
  inputMode="numeric"
  pattern="[0-9]*"
  name="creditCard"
/>

// MaxLength with character counter
<label htmlFor="bio">Bio (max 280 characters)</label>
<textarea
  id="bio"
  name="bio"
  maxLength={280}
  rows={4}
/>
```

## Input Validation Patterns

### Inline Validation with Debouncing

Validate as users type, but debounce to avoid overwhelming them:

```jsx
import { useState, useEffect } from "react";

function EmailInput() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState("");
  const [touched, setTouched] = useState(false);

  useEffect(() => {
    if (!touched) return;

    const timer = setTimeout(() => {
      if (!email) {
        setError("Email is required");
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        setError("Please enter a valid email address");
      } else {
        setError("");
      }
    }, 500); // Debounce 500ms

    return () => clearTimeout(timer);
  }, [email, touched]);

  return (
    <div className="form-field">
      <label htmlFor="email">Email Address</label>
      <input
        type="email"
        id="email"
        name="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        onBlur={() => setTouched(true)}
        aria-invalid={error ? "true" : "false"}
        aria-describedby={error ? "email-error" : undefined}
      />
      {error && (
        <span id="email-error" className="error-message" role="alert">
          {error}
        </span>
      )}
    </div>
  );
}
```

### Validation States

Provide clear visual feedback for validation states:

```jsx
// Success state
<div className="form-field form-field--success">
  <label htmlFor="username">Username</label>
  <input
    type="text"
    id="username"
    name="username"
    aria-invalid="false"
  />
  <span className="success-message">
    ✓ Username is available
  </span>
</div>

// Error state
<div className="form-field form-field--error">
  <label htmlFor="password">Password</label>
  <input
    type="password"
    id="password"
    name="password"
    aria-invalid="true"
    aria-describedby="password-error"
  />
  <span id="password-error" className="error-message" role="alert">
    Password must be at least 8 characters
  </span>
</div>
```

### Password Strength Indicator

```jsx
function PasswordInput() {
  const [password, setPassword] = useState("");
  const [strength, setStrength] = useState(0);

  const calculateStrength = (pwd) => {
    let score = 0;
    if (pwd.length >= 8) score++;
    if (pwd.length >= 12) score++;
    if (/[a-z]/.test(pwd) && /[A-Z]/.test(pwd)) score++;
    if (/\d/.test(pwd)) score++;
    if (/[^a-zA-Z0-9]/.test(pwd)) score++;
    return score;
  };

  useEffect(() => {
    setStrength(calculateStrength(password));
  }, [password]);

  const strengthLabels = ["", "Weak", "Fair", "Good", "Strong", "Very Strong"];
  const strengthColors = ["", "red", "orange", "yellow", "lightgreen", "green"];

  return (
    <div className="form-field">
      <label htmlFor="password">Password</label>
      <input
        type="password"
        id="password"
        name="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        aria-describedby="password-strength"
      />
      {password && (
        <div
          id="password-strength"
          className="password-strength"
          aria-live="polite"
        >
          <div
            className="strength-bar"
            style={{
              width: `${(strength / 5) * 100}%`,
              backgroundColor: strengthColors[strength],
            }}
          />
          <span>{strengthLabels[strength]}</span>
        </div>
      )}
    </div>
  );
}
```

## Accessible Error Handling

### ARIA Live Regions

Use ARIA live regions to announce errors to screen reader users:

```jsx
function FormWithErrors() {
  const [errors, setErrors] = useState([]);

  const handleSubmit = (e) => {
    e.preventDefault();
    const newErrors = validateForm();
    setErrors(newErrors);

    // Focus first error field
    if (newErrors.length > 0) {
      const firstErrorField = document.getElementById(newErrors[0].field);
      firstErrorField?.focus();
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Error summary - announced to screen readers */}
      {errors.length > 0 && (
        <div
          className="error-summary"
          role="alert"
          aria-live="assertive"
          tabIndex={-1}
        >
          <h2>Please fix the following errors:</h2>
          <ul>
            {errors.map((error, index) => (
              <li key={index}>
                <a href={`#${error.field}`}>{error.message}</a>
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* Form fields */}
      <div className="form-field">
        <label htmlFor="name">Full Name</label>
        <input
          type="text"
          id="name"
          name="name"
          aria-invalid={errors.some((e) => e.field === "name")}
          aria-describedby={
            errors.some((e) => e.field === "name") ? "name-error" : undefined
          }
        />
        {errors.find((e) => e.field === "name") && (
          <span id="name-error" className="error-message" role="alert">
            {errors.find((e) => e.field === "name").message}
          </span>
        )}
      </div>

      <button type="submit">Submit</button>
    </form>
  );
}
```

### Error Message Best Practices

**Good error messages are:**

- **Specific**: Tell users exactly what's wrong
- **Actionable**: Explain how to fix the issue
- **Polite**: Use friendly, non-technical language
- **Timely**: Appear when the error occurs

```jsx
// Bad error messages
"Invalid input";
"Error 422";
"Field required";

// Good error messages
"Please enter your email address";
"Email must include an @ symbol (e.g., you@example.com)";
"Password must be at least 8 characters and include a number";
"Phone number should be 10 digits (e.g., 555-123-4567)";
```

### Field-Level Error Display

```jsx
function FormField({
  label,
  name,
  type = "text",
  error,
  required = false,
  ...props
}) {
  const hasError = Boolean(error);
  const errorId = `${name}-error`;
  const descriptionId = `${name}-description`;

  return (
    <div className={`form-field ${hasError ? "form-field--error" : ""}`}>
      <label htmlFor={name}>
        {label}
        {required && <span aria-label="required"> *</span>}
      </label>

      <input
        type={type}
        id={name}
        name={name}
        required={required}
        aria-required={required}
        aria-invalid={hasError}
        aria-describedby={hasError ? errorId : descriptionId}
        {...props}
      />

      {hasError && (
        <span id={errorId} className="error-message" role="alert">
          {error}
        </span>
      )}
    </div>
  );
}
```

## Complete Form Examples

### Example 1: Contact Form with Validation

```jsx
import { useState } from "react";

function ContactForm() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    message: "",
  });

  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);

  const validateField = (name, value) => {
    switch (name) {
      case "name":
        if (!value.trim()) return "Name is required";
        if (value.trim().length < 2)
          return "Name must be at least 2 characters";
        return "";

      case "email":
        if (!value.trim()) return "Email is required";
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
          return "Please enter a valid email address (e.g., you@example.com)";
        }
        return "";

      case "phone":
        if (!value.trim()) return "Phone number is required";
        const cleaned = value.replace(/\D/g, "");
        if (cleaned.length !== 10) {
          return "Phone number must be 10 digits (e.g., 555-123-4567)";
        }
        return "";

      case "message":
        if (!value.trim()) return "Message is required";
        if (value.trim().length < 10) {
          return "Message must be at least 10 characters";
        }
        return "";

      default:
        return "";
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));

    // Validate if field has been touched
    if (touched[name]) {
      const error = validateField(name, value);
      setErrors((prev) => ({ ...prev, [name]: error }));
    }
  };

  const handleBlur = (e) => {
    const { name, value } = e.target;
    setTouched((prev) => ({ ...prev, [name]: true }));

    const error = validateField(name, value);
    setErrors((prev) => ({ ...prev, [name]: error }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Validate all fields
    const newErrors = {};
    Object.keys(formData).forEach((key) => {
      const error = validateField(key, formData[key]);
      if (error) newErrors[key] = error;
    });

    setErrors(newErrors);
    setTouched({
      name: true,
      email: true,
      phone: true,
      message: true,
    });

    // If errors exist, focus first error field
    if (Object.keys(newErrors).length > 0) {
      const firstErrorField = Object.keys(newErrors)[0];
      document.getElementById(firstErrorField)?.focus();
      return;
    }

    // Submit form
    setIsSubmitting(true);
    try {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1000));
      setSubmitSuccess(true);
      setFormData({ name: "", email: "", phone: "", message: "" });
      setTouched({});
    } catch (error) {
      setErrors({ submit: "Failed to submit form. Please try again." });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} noValidate>
      <h2>Contact Us</h2>

      {submitSuccess && (
        <div className="success-message" role="status" aria-live="polite">
          Thank you! Your message has been sent successfully.
        </div>
      )}

      {errors.submit && (
        <div className="error-summary" role="alert" aria-live="assertive">
          {errors.submit}
        </div>
      )}

      <div className="form-field">
        <label htmlFor="name">
          Full Name <span aria-label="required">*</span>
        </label>
        <input
          type="text"
          id="name"
          name="name"
          value={formData.name}
          onChange={handleChange}
          onBlur={handleBlur}
          required
          aria-required="true"
          aria-invalid={errors.name ? "true" : "false"}
          aria-describedby={errors.name ? "name-error" : undefined}
          autoComplete="name"
        />
        {errors.name && (
          <span id="name-error" className="error-message" role="alert">
            {errors.name}
          </span>
        )}
      </div>

      <div className="form-field">
        <label htmlFor="email">
          Email Address <span aria-label="required">*</span>
        </label>
        <input
          type="email"
          id="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          onBlur={handleBlur}
          required
          aria-required="true"
          aria-invalid={errors.email ? "true" : "false"}
          aria-describedby={errors.email ? "email-error" : undefined}
          autoComplete="email"
          placeholder="you@example.com"
        />
        {errors.email && (
          <span id="email-error" className="error-message" role="alert">
            {errors.email}
          </span>
        )}
      </div>

      <div className="form-field">
        <label htmlFor="phone">
          Phone Number <span aria-label="required">*</span>
        </label>
        <input
          type="tel"
          id="phone"
          name="phone"
          value={formData.phone}
          onChange={handleChange}
          onBlur={handleBlur}
          required
          aria-required="true"
          aria-invalid={errors.phone ? "true" : "false"}
          aria-describedby={errors.phone ? "phone-error" : undefined}
          autoComplete="tel"
          placeholder="555-123-4567"
        />
        {errors.phone && (
          <span id="phone-error" className="error-message" role="alert">
            {errors.phone}
          </span>
        )}
      </div>

      <div className="form-field">
        <label htmlFor="message">
          Message <span aria-label="required">*</span>
        </label>
        <textarea
          id="message"
          name="message"
          value={formData.message}
          onChange={handleChange}
          onBlur={handleBlur}
          required
          aria-required="true"
          aria-invalid={errors.message ? "true" : "false"}
          aria-describedby={errors.message ? "message-error" : undefined}
          rows={5}
          placeholder="How can we help you?"
        />
        {errors.message && (
          <span id="message-error" className="error-message" role="alert">
            {errors.message}
          </span>
        )}
      </div>

      <button type="submit" disabled={isSubmitting} aria-busy={isSubmitting}>
        {isSubmitting ? "Sending..." : "Send Message"}
      </button>
    </form>
  );
}
```

### Example 2: Multi-Step Registration Form

```jsx
function RegistrationForm() {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    // Step 1
    email: "",
    password: "",
    confirmPassword: "",
    // Step 2
    firstName: "",
    lastName: "",
    phone: "",
    // Step 3
    address: "",
    city: "",
    state: "",
    zip: "",
  });

  const totalSteps = 3;

  const nextStep = () => {
    if (validateCurrentStep()) {
      setStep((prev) => Math.min(prev + 1, totalSteps));
    }
  };

  const prevStep = () => {
    setStep((prev) => Math.max(prev - 1, 1));
  };

  const validateCurrentStep = () => {
    // Validation logic for current step
    return true;
  };

  return (
    <form>
      {/* Progress indicator */}
      <div
        className="progress-indicator"
        role="progressbar"
        aria-valuenow={step}
        aria-valuemin={1}
        aria-valuemax={totalSteps}
      >
        <span className="sr-only">
          Step {step} of {totalSteps}
        </span>
        <div className="progress-steps">
          {[1, 2, 3].map((s) => (
            <div
              key={s}
              className={`progress-step ${s <= step ? "active" : ""}`}
              aria-current={s === step ? "step" : undefined}
            >
              {s}
            </div>
          ))}
        </div>
      </div>

      {/* Step content */}
      {step === 1 && (
        <fieldset>
          <legend>Account Information</legend>
          {/* Account fields */}
        </fieldset>
      )}

      {step === 2 && (
        <fieldset>
          <legend>Personal Information</legend>
          {/* Personal fields */}
        </fieldset>
      )}

      {step === 3 && (
        <fieldset>
          <legend>Address Information</legend>
          {/* Address fields */}
        </fieldset>
      )}

      {/* Navigation */}
      <div className="form-navigation">
        {step > 1 && (
          <button type="button" onClick={prevStep}>
            Previous
          </button>
        )}
        {step < totalSteps ? (
          <button type="button" onClick={nextStep}>
            Next
          </button>
        ) : (
          <button type="submit">Complete Registration</button>
        )}
      </div>
    </form>
  );
}
```

## Form Styling Best Practices

### Visual Hierarchy

```css
/* Clear visual hierarchy for form elements */
.form-field {
  margin-bottom: 1.5rem;
}

.form-field label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #333;
}

.form-field input,
.form-field textarea,
.form-field select {
  width: 100%;
  padding: 0.75rem;
  font-size: 1rem;
  border: 2px solid #ddd;
  border-radius: 4px;
  transition: border-color 0.2s;
}

.form-field input:focus,
.form-field textarea:focus,
.form-field select:focus {
  outline: none;
  border-color: #0066cc;
  box-shadow: 0 0 0 3px rgba(0, 102, 204, 0.1);
}

/* Error state */
.form-field--error input,
.form-field--error textarea,
.form-field--error select {
  border-color: #d32f2f;
}

.error-message {
  display: block;
  margin-top: 0.5rem;
  color: #d32f2f;
  font-size: 0.875rem;
}

/* Success state */
.form-field--success input {
  border-color: #2e7d32;
}

.success-message {
  display: block;
  margin-top: 0.5rem;
  color: #2e7d32;
  font-size: 0.875rem;
}

/* Required indicator */
.form-field label [aria-label="required"] {
  color: #d32f2f;
}
```

### Focus Indicators

Always provide clear focus indicators for keyboard navigation:

```css
/* Visible focus indicator */
input:focus,
button:focus,
select:focus,
textarea:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* High contrast mode support */
@media (prefers-contrast: high) {
  input:focus,
  button:focus {
    outline: 3px solid currentColor;
  }
}
```

## Testing Forms

### Accessibility Testing Checklist

- [ ] All inputs have associated labels
- [ ] Required fields are marked with `required` and `aria-required`
- [ ] Error messages are associated with inputs via `aria-describedby`
- [ ] Error messages use `role="alert"` or `aria-live="assertive"`
- [ ] Form can be completed using keyboard only
- [ ] Focus order is logical
- [ ] Focus indicators are clearly visible
- [ ] Error summary appears at top of form with links to fields
- [ ] Success messages are announced to screen readers
- [ ] Form works with screen readers (test with NVDA, JAWS, VoiceOver)

### Manual Testing

1. **Keyboard Navigation**: Tab through entire form, verify all fields are reachable
2. **Screen Reader**: Use screen reader to complete form, verify all labels and errors are announced
3. **Mobile Testing**: Test on actual mobile devices, verify correct keyboards appear
4. **Error Handling**: Trigger all validation errors, verify messages are clear
5. **Success Flow**: Complete form successfully, verify confirmation message

### Automated Testing

```jsx
// Example with React Testing Library
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import ContactForm from "./ContactForm";

test("shows error when email is invalid", async () => {
  render(<ContactForm />);

  const emailInput = screen.getByLabelText(/email/i);
  await userEvent.type(emailInput, "invalid-email");
  await userEvent.tab(); // Trigger blur

  await waitFor(() => {
    expect(screen.getByRole("alert")).toHaveTextContent(/valid email/i);
  });
});

test("submits form with valid data", async () => {
  render(<ContactForm />);

  await userEvent.type(screen.getByLabelText(/name/i), "John Doe");
  await userEvent.type(screen.getByLabelText(/email/i), "john@example.com");
  await userEvent.type(screen.getByLabelText(/phone/i), "5551234567");
  await userEvent.type(screen.getByLabelText(/message/i), "Test message here");

  await userEvent.click(screen.getByRole("button", { name: /send/i }));

  await waitFor(() => {
    expect(screen.getByRole("status")).toHaveTextContent(/success/i);
  });
});
```

## Common Pitfalls to Avoid

### ❌ Don't Use Placeholder as Label

```jsx
// Bad: Placeholder disappears when typing
<input type="text" placeholder="Email Address" />

// Good: Persistent label with optional placeholder
<label htmlFor="email">Email Address</label>
<input type="email" id="email" placeholder="you@example.com" />
```

### ❌ Don't Validate Too Aggressively

```jsx
// Bad: Shows error immediately on first keystroke
onChange={(e) => {
  if (!isValid(e.target.value)) {
    setError('Invalid input');
  }
}}

// Good: Wait for blur or debounce
onBlur={() => validateField()}
```

### ❌ Don't Disable Submit Button

```jsx
// Bad: Prevents form submission, confusing for users
<button type="submit" disabled={hasErrors}>Submit</button>

// Good: Allow submission, show errors on submit
<button type="submit">Submit</button>
```

### ❌ Don't Use Generic Error Messages

```jsx
// Bad
"Invalid input";

// Good
"Email must include an @ symbol (e.g., you@example.com)";
```

## Resources

- [W3C Form Validation](https://www.w3.org/WAI/tutorials/forms/validation/)
- [WebAIM: Creating Accessible Forms](https://webaim.org/techniques/forms/)
- [MDN: HTML Forms Guide](https://developer.mozilla.org/en-US/docs/Learn/Forms)
- [GOV.UK Design System: Form Patterns](https://design-system.service.gov.uk/patterns/)
- [Nielsen Norman Group: Form Design](https://www.nngroup.com/articles/web-form-design/)
- [ARIA Authoring Practices: Form Patterns](https://www.w3.org/WAI/ARIA/apg/patterns/)
