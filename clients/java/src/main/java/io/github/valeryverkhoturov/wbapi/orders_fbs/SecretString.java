package io.github.valeryverkhoturov.wbapi.orders_fbs;

/**
 * Wrapper around a bearer JWT that redacts under toString(). Use {@link #exposeSecret} to get the
 * raw value — deliberately awkward so accidental leaks become explicit.
 */
public final class SecretString {
  private final String value;

  public SecretString(String value) {
    this.value = value;
  }

  public String exposeSecret() {
    return value;
  }

  @Override
  public String toString() {
    return "<REDACTED>";
  }
}
