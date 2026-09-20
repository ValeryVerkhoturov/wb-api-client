<?php

namespace ValeryVerkhoturov\WbApiClient\Rates;

/**
 * Wrapper around a bearer JWT that redacts under __toString().
 * Use exposeSecret() to get the raw value — deliberately awkward
 * so accidental leaks (var_dump/print_r/log) become explicit.
 */
final class SecretString
{
    private string $value;

    public function __construct(string $value)
    {
        $this->value = $value;
    }

    public function exposeSecret(): string
    {
        return $this->value;
    }

    public function __toString(): string
    {
        return '<REDACTED>';
    }

    public function __debugInfo(): array
    {
        return ['value' => '<REDACTED>'];
    }
}
